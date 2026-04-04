#if os(macOS)
import Cocoa
import QuickLookUI
#else
import UIKit
import QuickLook
#endif

#if os(macOS)
final class PreviewViewController: NSViewController, QLPreviewingController {
  private lazy var scrollView: NSScrollView = {
    let sv = NSScrollView()
    sv.hasVerticalScroller = true
    sv.hasHorizontalScroller = false
    sv.autohidesScrollers = true
    sv.drawsBackground = true
    sv.backgroundColor = .textBackgroundColor
    return sv
  }()

  private lazy var textView: NSTextView = {
    let tv = NSTextView()
    tv.isEditable = false
    tv.isSelectable = true
    tv.drawsBackground = true
    tv.backgroundColor = .textBackgroundColor
    tv.textContainerInset = NSSize(width: 20, height: 20)
    return tv
  }()

  override func loadView() {
    view = NSView()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.textBackgroundColor.cgColor
    scrollView.documentView = textView
    view.addSubview(scrollView)
  }

  override func viewDidLayout() {
    super.viewDidLayout()
    scrollView.frame = view.bounds
    let contentWidth = max(view.bounds.width - 40, 100)
    textView.minSize = NSSize(width: contentWidth, height: 0)
    textView.maxSize = NSSize(width: contentWidth, height: .greatestFiniteMagnitude)
    textView.textContainer?.containerSize = NSSize(width: contentWidth, height: .greatestFiniteMagnitude)
    textView.textContainer?.widthTracksTextView = false
  }

  func preparePreviewOfFile(at url: URL) async throws {
    let fileURL = textFileURL(of: url)
    let data = try Data(contentsOf: fileURL)
    let markdown = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii) ?? ""

    let dark = view.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    let bgColor: NSColor = dark
      ? NSColor(red: 0.118, green: 0.118, blue: 0.118, alpha: 1)
      : .textBackgroundColor
    scrollView.backgroundColor = bgColor
    textView.backgroundColor = bgColor
    view.layer?.backgroundColor = bgColor.cgColor

    let html = renderedHTML(for: markdown, isDarkMode: dark)
    let htmlData = Data(html.utf8)

    if let attrString = NSAttributedString(
      html: htmlData,
      documentAttributes: nil
    ) {
      textView.textStorage?.setAttributedString(attrString)
    } else {
      textView.string = markdown
    }
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

final class PreviewViewController: UIViewController, QLPreviewingController {
  private lazy var textView: UITextView = {
    let tv = UITextView()
    tv.isEditable = false
    tv.isSelectable = true
    tv.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    return tv
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    textView.frame = view.bounds
    textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(textView)
  }

  func preparePreviewOfFile(at url: URL) async throws {
    let fileURL = textFileURL(of: url)
    let data = try Data(contentsOf: fileURL)
    let markdown = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii) ?? ""

    let dark = traitCollection.userInterfaceStyle == .dark
    let html = renderedHTML(for: markdown, isDarkMode: dark)
    let htmlData = Data(html.utf8)

    if let attrString = try? NSAttributedString(
      data: htmlData,
      options: [.documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue],
      documentAttributes: nil
    ) {
      textView.attributedText = attrString
    } else {
      textView.text = markdown
    }
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
