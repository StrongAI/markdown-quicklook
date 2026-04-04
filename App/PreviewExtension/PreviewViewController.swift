#if os(macOS)
import Cocoa
import QuickLookUI
#else
import UIKit
import QuickLook
#endif
import WebKit

#if os(macOS)
final class PreviewViewController: NSViewController, QLPreviewingController {
  private var appearanceObservation: NSKeyValueObservation?

  private lazy var webView: WKWebView = {
    let config = WKWebViewConfiguration()
    let webView = WKWebView(frame: .zero, configuration: config)
    webView.allowsMagnification = true
    return webView
  }()

  override func loadView() {
    view = NSView()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.wantsLayer = true
    view.addSubview(webView)
    view.layer?.masksToBounds = true
    view.layer?.cornerRadius = 6

    updateBackgroundColor()

    appearanceObservation = NSApp.observe(\.effectiveAppearance) { [weak self] _, _ in
      guard let self else { return }
      Task { @MainActor in
        self.updateBackgroundColor()
      }
    }
  }

  override func viewDidLayout() {
    super.viewDidLayout()
    webView.frame = view.bounds
  }

  func preparePreviewOfFile(at url: URL) async throws {
    let fileURL = textFileURL(of: url)
    let data = try Data(contentsOf: fileURL)
    let markdown = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii) ?? ""
    let html = renderedHTML(for: markdown)
    webView.loadHTMLString(html, baseURL: nil)
  }

  private var isDarkMode: Bool {
    switch NSApp.effectiveAppearance.name {
    case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
      return true
    default:
      return false
    }
  }

  private func updateBackgroundColor() {
    view.layer?.backgroundColor = (isDarkMode
      ? NSColor(red: 13.0 / 255, green: 17.0 / 255, blue: 22.0 / 255, alpha: 1)
      : NSColor.white
    ).cgColor
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
final class PreviewViewController: UIViewController, QLPreviewingController {
  private lazy var webView: WKWebView = {
    let config = WKWebViewConfiguration()
    let webView = WKWebView(frame: .zero, configuration: config)
    return webView
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
    let html = renderedHTML(for: markdown)
    webView.loadHTMLString(html, baseURL: nil)
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
  func renderedHTML(for markdown: String) -> String {
    guard let templateURL = Bundle(for: Self.self).url(forResource: "index", withExtension: "html"),
          let template = try? String(contentsOf: templateURL, encoding: .utf8) else {
      return "<html><body><pre>\(markdown)</pre></body></html>"
    }

    // Escape the markdown for safe embedding in the HTML template's <pre> element.
    let escaped = markdown
      .replacingOccurrences(of: "&", with: "&amp;")
      .replacingOccurrences(of: "<", with: "&lt;")
      .replacingOccurrences(of: ">", with: "&gt;")

    return template.replacingOccurrences(of: "<!--MARKDOWN_SOURCE-->", with: escaped)
  }
}
