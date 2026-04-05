#if os(macOS)
import Cocoa
import QuickLookUI
import WebKit

final class PreviewViewController: NSViewController, QLPreviewingController {
  // Zoom is a static preference set in the host app. The QL panel blocks
  // ALL input to extensions (keyboard, gestures, HTML clicks), so interactive
  // zoom is not possible. The host app writes to the shared app group and
  // the extension reads it on each preview.
  private static let zoomKey = "PreviewZoomLevel"

  private lazy var webView: WKWebView = {
    let config = WKWebViewConfiguration()
    let wv = WKWebView(frame: .zero, configuration: config)
    wv.setValue(false, forKey: "drawsBackground")
    return wv
  }()

  override func loadView() {
    view = NSView()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    webView.frame = view.bounds
    webView.autoresizingMask = [.width, .height]
    view.addSubview(webView)
  }

  private static let suiteName = "CJN5CYF28H.ai.strong.Markdown.QuickLook"

  private var zoomLevel: Double {
    let zoom = UserDefaults(suiteName: Self.suiteName)?.double(forKey: Self.zoomKey) ?? 0
    return zoom > 0 ? zoom : 1.0
  }

  func preparePreviewOfFile(at url: URL) async throws {
    let fileURL = textFileURL(of: url)
    let data = try Data(contentsOf: fileURL)
    let markdown = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii) ?? ""

    let dark = view.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    var renderer = MarkdownToHTML(isDarkMode: dark)
    let zoom = zoomLevel
    let zoomCSS = zoom != 1.0 ? "body { zoom: \(zoom); }" : ""
    let html = renderer.render(markdown).replacingOccurrences(of: "</style>", with: "\(zoomCSS)</style>")
    webView.loadHTMLString(html, baseURL: fileURL.deletingLastPathComponent())
  }

  private func textFileURL(of url: URL) -> URL {
    if url.pathExtension.lowercased() == "textbundle",
       let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) {
      return contents.first {
        let filename = $0.lastPathComponent.lowercased()
        return filename.hasPrefix("text.") && filename != "text.html"
      } ?? url
    }
    return url
  }
}

#else
import UIKit
import QuickLook
import WebKit

final class PreviewViewController: UIViewController, QLPreviewingController {
  private lazy var webView: WKWebView = {
    let config = WKWebViewConfiguration()
    let wv = WKWebView(frame: .zero, configuration: config)
    wv.isOpaque = false
    wv.backgroundColor = .clear
    return wv
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    webView.frame = view.bounds
    webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(webView)
  }

  func preparePreviewOfFile(at url: URL) async throws {
    let fileURL = textFileURL(of: url)
    let data = try Data(contentsOf: fileURL)
    let markdown = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii) ?? ""

    let dark = traitCollection.userInterfaceStyle == .dark
    var renderer = MarkdownToHTML(isDarkMode: dark)
    let html = renderer.render(markdown)
    webView.loadHTMLString(html, baseURL: fileURL.deletingLastPathComponent())
  }

  private func textFileURL(of url: URL) -> URL {
    if url.pathExtension.lowercased() == "textbundle",
       let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) {
      return contents.first {
        let filename = $0.lastPathComponent.lowercased()
        return filename.hasPrefix("text.") && filename != "text.html"
      } ?? url
    }
    return url
  }
}
#endif
