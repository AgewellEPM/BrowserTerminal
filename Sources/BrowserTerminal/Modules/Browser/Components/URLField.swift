import SwiftUI

struct URLField: View {
    @ObservedObject var viewModel: BrowserToolbarViewModel
    @FocusState private var isURLFieldFocused: Bool

    var body: some View {
        HStack {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(0.5)
                    .frame(width: 16, height: 16)
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12))
                    .foregroundColor(viewModel.isSecure ? .green : .secondary)
            }

            TextField("Enter URL", text: $viewModel.urlText, onEditingChanged: { editing in
                viewModel.isEditing = editing
            }, onCommit: {
                viewModel.navigateToURL()
            })
            .textFieldStyle(PlainTextFieldStyle())
            .focused($isURLFieldFocused)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(6)
    }
}