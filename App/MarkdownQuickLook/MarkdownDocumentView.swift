#if os(iOS)
import SwiftUI
import WebKit

struct MarkdownDocumentView: View {
  @Binding var document: MarkdownDocument
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    MarkdownWebView(
      markdown: document.text,
      isDarkMode: colorScheme == .dark
    )
    .ignoresSafeArea(edges: .bottom)
  }
}

struct MarkdownWebView: UIViewRepresentable {
  let markdown: String
  let isDarkMode: Bool

  func makeUIView(context: Context) -> WKWebView {
    let config = WKWebViewConfiguration()
    let wv = WKWebView(frame: .zero, configuration: config)
    wv.isOpaque = false
    wv.backgroundColor = .clear
    return wv
  }

  func updateUIView(_ wv: WKWebView, context: Context) {
    var renderer = MarkdownToHTML(isDarkMode: isDarkMode)
    let html = renderer.render(markdown)
    wv.loadHTMLString(html, baseURL: nil)
  }
}
#endif
