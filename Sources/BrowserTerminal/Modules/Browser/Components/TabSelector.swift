import SwiftUI

struct TabSelector: View {
    @ObservedObject var browserManager: BrowserManager

    var body: some View {
        Menu {
            ForEach(browserManager.tabs) { tab in
                Button(action: {
                    browserManager.activeTabId = tab.id
                }) {
                    HStack {
                        Text(tab.title)
                            .lineLimit(1)
                        if tab.id == browserManager.activeTabId {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            Divider()
            Button("New Tab") {
                browserManager.addTab()
            }
        } label: {
            HStack(spacing: 2) {
                Text("\(browserManager.tabs.count)")
                    .font(.system(size: 10))
                Image(systemName: "square.on.square")
            }
        }
        .menuStyle(BorderlessButtonMenuStyle())
        .frame(width: 44)
    }
}