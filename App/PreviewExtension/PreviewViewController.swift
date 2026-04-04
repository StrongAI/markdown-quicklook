#if os(macOS)
import Cocoa
import QuickLookUI
import WebKit

final class PreviewViewController: NSViewController, QLPreviewingController {
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

  func preparePreviewOfFile(at url: URL) async throws {
    let fileURL = textFileURL(of: url)
    let data = try Data(contentsOf: fileURL)
    let markdown = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii) ?? ""

    let dark = view.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    let html = renderedHTML(for: markdown, isDarkMode: dark)
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
    let html = renderedHTML(for: markdown, isDarkMode: dark)
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

// MARK: - Shared Rendering

extension PreviewViewController {
  func renderedHTML(for markdown: String, isDarkMode: Bool) -> String {
    var renderer = MarkdownToHTML(isDarkMode: isDarkMode)
    return renderer.render(markdown)
  }
}
