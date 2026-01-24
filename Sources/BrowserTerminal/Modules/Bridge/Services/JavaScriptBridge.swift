import Foundation

struct JavaScriptBridge {
    static let bridgeScript = """
        (function() {
            // Create global terminal bridge object
            window.terminalBridge = {
                // Execute command in terminal
                execute: function(command) {
                    window.webkit.messageHandlers.terminalBridge.postMessage({
                        action: 'execute',
                        command: command
                    });
                },

                // Open URL in browser
                openURL: function(url) {
                    window.webkit.messageHandlers.terminalBridge.postMessage({
                        action: 'openURL',
                        url: url
                    });
                },

                // Send data to terminal
                send: function(data) {
                    window.webkit.messageHandlers.terminalBridge.postMessage({
                        action: 'send',
                        data: data
                    });
                }
            };

            // Add keyboard shortcut to send selected text to terminal
            document.addEventListener('keydown', function(e) {
                // Cmd+Shift+T: Send selected text to terminal
                if (e.metaKey && e.shiftKey && e.key === 't') {
                    const selection = window.getSelection().toString();
                    if (selection) {
                        window.terminalBridge.execute(selection);
                        e.preventDefault();
                    }
                }
            });

            // Detect terminal commands in code blocks
            document.addEventListener('dblclick', function(e) {
                const target = e.target;
                if (target.tagName === 'CODE' || target.closest('pre')) {
                    const text = target.innerText || target.textContent;
                    if (text && text.trim().startsWith('$')) {
                        // Remove leading $ and execute
                        const command = text.trim().substring(1).trim();
                        if (confirm('Execute in terminal: ' + command + '?')) {
                            window.terminalBridge.execute(command);
                        }
                    }
                }
            });

            console.log('Terminal bridge initialized');
        })();
        """
}