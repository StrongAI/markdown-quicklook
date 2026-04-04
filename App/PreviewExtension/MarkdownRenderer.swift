import Foundation
import Markdown

struct MarkdownToHTML: MarkupVisitor {
  typealias Result = String

  private let isDarkMode: Bool

  init(isDarkMode: Bool) {
    self.isDarkMode = isDarkMode
  }

  mutating func render(_ markdown: String) -> String {
    let document = Document(parsing: markdown)
    let body = visit(document)
    return wrapInHTMLDocument(body)
  }

  // MARK: - Default

  mutating func defaultVisit(_ markup: Markup) -> String {
    content(of: markup)
  }

  // MARK: - Block Elements

  mutating func visitDocument(_ document: Document) -> String {
    content(of: document)
  }

  mutating func visitParagraph(_ paragraph: Paragraph) -> String {
    "<p>" + content(of: paragraph) + "</p>\n"
  }

  mutating func visitHeading(_ heading: Heading) -> String {
    "<h\(heading.level)>" + content(of: heading) + "</h\(heading.level)>\n"
  }

  mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> String {
    "<blockquote>\n" + content(of: blockQuote) + "</blockquote>\n"
  }

  mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> String {
    "<pre><code>" + escapeHTML(codeBlock.code) + "</code></pre>\n"
  }

  mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) -> String {
    "<hr>\n"
  }

  mutating func visitHTMLBlock(_ html: HTMLBlock) -> String {
    html.rawHTML
  }

  // MARK: - Lists

  mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> String {
    "<ul>\n" + content(of: unorderedList) + "</ul>\n"
  }

  mutating func visitOrderedList(_ orderedList: OrderedList) -> String {
    "<ol>\n" + content(of: orderedList) + "</ol>\n"
  }

  mutating func visitListItem(_ listItem: ListItem) -> String {
    "<li>" + content(of: listItem) + "</li>\n"
  }

  // MARK: - Tables

  mutating func visitTable(_ table: Table) -> String {
    "<table>\n" + content(of: table) + "</table>\n"
  }

  mutating func visitTableHead(_ tableHead: Table.Head) -> String {
    var result = "<thead>\n<tr>\n"
    for child in tableHead.children {
      result += "<th>" + visit(child) + "</th>\n"
    }
    result += "</tr>\n</thead>\n"
    return result
  }

  mutating func visitTableBody(_ tableBody: Table.Body) -> String {
    "<tbody>\n" + content(of: tableBody) + "</tbody>\n"
  }

  mutating func visitTableRow(_ tableRow: Table.Row) -> String {
    var result = "<tr>\n"
    for child in tableRow.children {
      result += "<td>" + visit(child) + "</td>\n"
    }
    result += "</tr>\n"
    return result
  }

  mutating func visitTableCell(_ tableCell: Table.Cell) -> String {
    content(of: tableCell)
  }

  // MARK: - Inline Elements

  mutating func visitText(_ text: Text) -> String {
    escapeHTML(text.string)
  }

  mutating func visitStrong(_ strong: Strong) -> String {
    "<strong>" + content(of: strong) + "</strong>"
  }

  mutating func visitEmphasis(_ emphasis: Emphasis) -> String {
    "<em>" + content(of: emphasis) + "</em>"
  }

  mutating func visitInlineCode(_ inlineCode: InlineCode) -> String {
    "<code>" + escapeHTML(inlineCode.code) + "</code>"
  }

  mutating func visitLink(_ link: Link) -> String {
    let href = link.destination ?? ""
    return "<a href=\"\(escapeHTML(href))\">" + content(of: link) + "</a>"
  }

  mutating func visitImage(_ image: Image) -> String {
    let src = image.source ?? ""
    var altText = ""
    for child in image.children {
      if let text = child as? Text {
        altText += text.string
      }
    }
    return "<img src=\"\(escapeHTML(src))\" alt=\"\(escapeHTML(altText))\">"
  }

  mutating func visitSoftBreak(_ softBreak: SoftBreak) -> String {
    "\n"
  }

  mutating func visitLineBreak(_ lineBreak: LineBreak) -> String {
    "<br>\n"
  }

  mutating func visitInlineHTML(_ html: InlineHTML) -> String {
    html.rawHTML
  }

  mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> String {
    "<del>" + content(of: strikethrough) + "</del>"
  }

  // MARK: - Helpers

  private mutating func content(of markup: Markup) -> String {
    var result = ""
    for child in markup.children {
      result += visit(child)
    }
    return result
  }

  private func escapeHTML(_ string: String) -> String {
    string
      .replacingOccurrences(of: "&", with: "&amp;")
      .replacingOccurrences(of: "<", with: "&lt;")
      .replacingOccurrences(of: ">", with: "&gt;")
      .replacingOccurrences(of: "\"", with: "&quot;")
  }

  // MARK: - HTML Document Wrapper

  private func wrapInHTMLDocument(_ body: String) -> String {
    let c = isDarkMode ? Self.dark : Self.light

    return """
    <html>
    <head><meta charset="UTF-8"></head>
    <body style="font-family: -apple-system, sans-serif; font-size: 14px; \
    line-height: 1.6; color: \(c.text); background-color: \(c.bg);">
    <style>
    body { margin: 0; padding: 0; }
    h1 { font-size: 28px; font-weight: 600; border-bottom: 1px solid \(c.border); \
    padding-bottom: 8px; margin-top: 24px; margin-bottom: 16px; }
    h2 { font-size: 22px; font-weight: 600; border-bottom: 1px solid \(c.border); \
    padding-bottom: 8px; margin-top: 24px; margin-bottom: 16px; }
    h3 { font-size: 18px; font-weight: 600; margin-top: 24px; margin-bottom: 16px; }
    h4 { font-size: 16px; font-weight: 600; margin-top: 24px; margin-bottom: 16px; }
    h5 { font-size: 14px; font-weight: 600; margin-top: 24px; margin-bottom: 16px; }
    h6 { font-size: 13px; font-weight: 600; margin-top: 24px; margin-bottom: 16px; \
    color: \(c.muted); }
    p { margin-top: 0; margin-bottom: 16px; }
    a { color: \(c.link); }
    code { font-family: 'SF Mono', Menlo, monospace; font-size: 12px; \
    background-color: \(c.codeBg); padding: 2px 6px; }
    pre { background-color: \(c.codeBg); padding: 16px; margin-bottom: 16px; }
    pre code { background: none; padding: 0; }
    blockquote { border-left: 4px solid \(c.bqBorder); padding-left: 16px; \
    color: \(c.muted); margin: 0 0 16px 0; }
    table { border-collapse: collapse; margin-bottom: 16px; }
    th, td { border: 1px solid \(c.border); padding: 6px 13px; }
    th { font-weight: 600; background-color: \(c.codeBg); }
    hr { border: none; border-top: 1px solid \(c.border); margin: 24px 0; }
    ul, ol { padding-left: 2em; margin-bottom: 16px; }
    li { margin-bottom: 4px; }
    del { text-decoration: line-through; }
    </style>
    \(body)
    </body>
    </html>
    """
  }

  private struct Colors {
    let bg: String
    let text: String
    let link: String
    let codeBg: String
    let border: String
    let bqBorder: String
    let muted: String
  }

  private static let light = Colors(
    bg: "#ffffff",
    text: "#1f2328",
    link: "#0969da",
    codeBg: "#f6f8fa",
    border: "#d0d7de",
    bqBorder: "#d0d7de",
    muted: "#656d76"
  )

  private static let dark = Colors(
    bg: "#1e1e1e",
    text: "#d4d4d4",
    link: "#58a6ff",
    codeBg: "#2d2d2d",
    border: "#444444",
    bqBorder: "#555555",
    muted: "#999999"
  )
}
