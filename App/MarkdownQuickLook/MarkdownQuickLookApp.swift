import SwiftUI

@main
struct MarkdownQuickLookApp: App {
  var body: some Scene {
    #if os(macOS)
    Window("Markdown QuickLook", id: "main") {
      ContentView()
    }
    .defaultSize(width: 480, height: 360)
    #else
    DocumentGroup(viewing: MarkdownDocument.self) { file in
      MarkdownDocumentView(document: file.$document)
    }
    #endif
  }
}
