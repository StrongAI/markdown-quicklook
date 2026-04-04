import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack(spacing: 20) {
      Image(systemName: "doc.richtext")
        .font(.system(size: 64))
        .foregroundStyle(.secondary)

      Text("Markdown QuickLook")
        .font(.title)
        .fontWeight(.semibold)

      Text("This app provides a QuickLook extension for previewing Markdown files.")
        .multilineTextAlignment(.center)
        .foregroundStyle(.secondary)
        .frame(maxWidth: 320)

      #if os(macOS)
      Text("The extension is active automatically. Select a Markdown file in Finder and press Space to preview it.")
        .multilineTextAlignment(.center)
        .foregroundStyle(.tertiary)
        .font(.callout)
        .frame(maxWidth: 320)
      #else
      Text("The extension is active automatically. Tap a Markdown file in the Files app to preview it.")
        .multilineTextAlignment(.center)
        .foregroundStyle(.tertiary)
        .font(.callout)
        .frame(maxWidth: 320)
      #endif
    }
    .padding(40)
  }
}
