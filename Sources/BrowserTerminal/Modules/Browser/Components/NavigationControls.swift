import SwiftUI

struct NavigationControls: View {
    @ObservedObject var viewModel: BrowserToolbarViewModel

    var body: some View {
        HStack(spacing: 4) {
            Button(action: viewModel.goBack) {
                Image(systemName: "chevron.left")
                    .foregroundColor(viewModel.canGoBack ? .primary : .secondary)
            }
            .disabled(!viewModel.canGoBack)
            .buttonStyle(ToolbarButtonStyle())

            Button(action: viewModel.goForward) {
                Image(systemName: "chevron.right")
                    .foregroundColor(viewModel.canGoForward ? .primary : .secondary)
            }
            .disabled(!viewModel.canGoForward)
            .buttonStyle(ToolbarButtonStyle())

            Button(action: viewModel.reload) {
                Image(systemName: viewModel.isLoading ? "xmark" : "arrow.clockwise")
            }
            .buttonStyle(ToolbarButtonStyle())
        }
    }
}

struct ToolbarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 28, height: 28)
            .background(configuration.isPressed ? Color.gray.opacity(0.2) : Color.clear)
            .cornerRadius(4)
    }
}