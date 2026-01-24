import Foundation
import Darwin
import Dispatch

protocol PTYControllerDelegate: AnyObject {
    func ptyController(_ controller: PTYController, didReceiveData data: Data)
    func ptyControllerDidTerminate(_ controller: PTYController)
}

class PTYController {
    weak var delegate: PTYControllerDelegate?

    private var masterFD: Int32 = -1
    private var slaveFD: Int32 = -1
    private var shellProcess: Process?
    private var readSource: DispatchSourceRead?
    private var isRunning = false

    private let readQueue = DispatchQueue(label: "pty.read", qos: .userInteractive)
    private let writeQueue = DispatchQueue(label: "pty.write", qos: .userInteractive)

    func start() {
        guard !isRunning else { return }

        if !createPTY() {
            print("Failed to create PTY")
            return
        }

        startShell()
        setupReadMonitoring()
        isRunning = true
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false

        readSource?.cancel()
        readSource = nil
        shellProcess?.terminate()
        shellProcess = nil

        if masterFD >= 0 {
            close(masterFD)
            masterFD = -1
        }
        if slaveFD >= 0 {
            close(slaveFD)
            slaveFD = -1
        }

        delegate?.ptyControllerDidTerminate(self)
    }

    func write(_ data: Data) {
        guard isRunning, masterFD >= 0 else { return }

        writeQueue.async { [weak self] in
            guard let self = self else { return }
            data.withUnsafeBytes { bytes in
                _ = Darwin.write(self.masterFD, bytes.baseAddress, bytes.count)
            }
        }
    }

    func resize(rows: Int, cols: Int) {
        guard masterFD >= 0 || slaveFD >= 0 else { return }

        var winSize = winsize()
        winSize.ws_row = UInt16(rows)
        winSize.ws_col = UInt16(cols)
        winSize.ws_xpixel = 0
        winSize.ws_ypixel = 0

        if masterFD >= 0 { _ = ioctl(masterFD, TIOCSWINSZ, &winSize) }
        if slaveFD >= 0 { _ = ioctl(slaveFD, TIOCSWINSZ, &winSize) }

        if let pid = shellProcess?.processIdentifier {
            _ = kill(pid, SIGWINCH)
        }
    }

    private func createPTY() -> Bool {
        var masterFD: Int32 = 0
        var slaveFD: Int32 = 0

        let result = openpty(&masterFD, &slaveFD, nil, nil, nil)
        if result != 0 {
            return false
        }

        self.masterFD = masterFD
        self.slaveFD = slaveFD

        // Configure master FD for non-blocking I/O
        var flags = fcntl(masterFD, F_GETFL, 0)
        if flags == -1 {
            close(masterFD)
            close(slaveFD)
            return false
        }
        flags |= O_NONBLOCK
        if fcntl(masterFD, F_SETFL, flags) == -1 {
            close(masterFD)
            close(slaveFD)
            return false
        }

        resize(rows: 24, cols: 80)
        return true
    }

    private func startShell() {
        let process = Process()
        let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"

        process.executableURL = URL(fileURLWithPath: shell)
        process.arguments = ["-l"]

        var environment = ProcessInfo.processInfo.environment
        environment["TERM"] = "xterm-256color"
        environment["LANG"] = environment["LANG"] ?? "en_US.UTF-8"
        environment["LC_ALL"] = environment["LC_ALL"] ?? "en_US.UTF-8"
        environment["COLORTERM"] = "truecolor"
        process.environment = environment

        process.standardInput = FileHandle(fileDescriptor: slaveFD)
        process.standardOutput = FileHandle(fileDescriptor: slaveFD)
        process.standardError = FileHandle(fileDescriptor: slaveFD)

        process.terminationHandler = { [weak self] _ in
            DispatchQueue.main.async {
                self?.stop()
            }
        }

        do {
            try process.run()
            shellProcess = process
            close(slaveFD)
            slaveFD = -1
        } catch {
            print("Failed to start shell: \\(error)")
            stop()
        }
    }

    private func setupReadMonitoring() {
        guard masterFD >= 0 else { return }

        readSource = DispatchSource.makeReadSource(fileDescriptor: masterFD, queue: readQueue)

        readSource?.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.readAvailableData()
        }

        readSource?.setCancelHandler { [weak self] in
            guard let self = self else { return }
            if self.masterFD >= 0 {
                close(self.masterFD)
                self.masterFD = -1
            }
        }

        readSource?.resume()
    }

    private func readAvailableData() {
        guard masterFD >= 0 else { return }

        let bufferSize = 8192
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }

        while true {
            let bytesRead = read(masterFD, buffer, bufferSize)

            if bytesRead > 0 {
                let data = Data(bytes: buffer, count: bytesRead)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.ptyController(self, didReceiveData: data)
                }
            } else if bytesRead == 0 || (bytesRead == -1 && errno == EAGAIN) {
                break
            } else {
                print("Read error: \\(errno)")
                stop()
                break
            }
        }
    }

    deinit {
        stop()
    }
}
