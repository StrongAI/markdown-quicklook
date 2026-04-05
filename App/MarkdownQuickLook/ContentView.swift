import SwiftUI

struct ContentView: View {
  private static let suiteName = "CJN5CYF28H.ai.strong.Markdown.QuickLook"
  private static let zoomKey = "PreviewZoomLevel"

  @State private var zoom: Double = {
    let v = UserDefaults(suiteName: suiteName)?.double(forKey: zoomKey) ?? 0
    return v > 0 ? v : 1.0
  }()

  var body: some View {
    VStack(spacing: 20) {
      Image(systemName: "doc.richtext")
        .font(.system(size: 64))
        .foregroundStyle(.secondary)

      Text("Markdown QuickLook v2")
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

      Divider().frame(maxWidth: 280)

      VStack(spacing: 8) {
        Text("Preview Zoom")
          .font(.headline)

        HStack(spacing: 12) {
          Button("−") { adjustZoom(by: -0.1) }
            .buttonStyle(.bordered)

          Text("\(Int(zoom * 100))%")
            .font(.system(.body, design: .monospaced))
            .frame(minWidth: 50)

          Button("+") { adjustZoom(by: 0.1) }
            .buttonStyle(.bordered)

          if zoom != 1.0 {
            Button("Reset") { setZoom(1.0) }
              .buttonStyle(.borderless)
              .foregroundStyle(.secondary)
          }
        }

        Text("Changes apply to the next QuickLook preview.")
          .font(.caption)
          .foregroundStyle(.tertiary)
      }
    }
    .padding(40)
  }

  private func adjustZoom(by delta: Double) {
    setZoom(zoom + delta)
  }

  private func setZoom(_ value: Double) {
    zoom = min(3.0, max(0.5, value))
    UserDefaults(suiteName: Self.suiteName)?.set(zoom, forKey: Self.zoomKey)
  }
}
