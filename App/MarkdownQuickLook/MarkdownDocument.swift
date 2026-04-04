import SwiftUI
import UniformTypeIdentifiers

struct MarkdownDocument: FileDocument {
  static var readableContentTypes: [UTType] {
    [
      UTType("net.daringfireball.markdown") ?? .plainText,
      .plainText,
    ]
  }

  var text: String

  init(text: String = "") {
    self.text = text
  }

  init(configuration: ReadConfiguration) throws {
    guard let data = configuration.file.regularFileContents else {
      throw CocoaError(.fileReadCorruptFile)
    }
    text = String(data: data, encoding: .utf8)
      ?? String(data: data, encoding: .ascii)
      ?? ""
  }

  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    FileWrapper(regularFileWithContents: Data(text.utf8))
  }
}
