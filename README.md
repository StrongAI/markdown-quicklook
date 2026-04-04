# Markdown QuickLook

A native macOS/iOS app for previewing Markdown files with rendered formatting, dark mode support, and task list checkboxes.

## macOS

Provides a QuickLook preview extension. Select any `.md` file in Finder and press Space to see rendered Markdown instead of raw text.

Supported file types: `.md`, `.markdown`, `.mdown`, `.mkd`, `.mkdn`, `.textbundle`, `.qmd`, `.rmd`

## iOS

A document-based viewer. Open the app to browse for Markdown files, or use "Open With" from the Files app.

iOS does not allow third-party QuickLook extensions to override system-owned file types, so the QuickLook extension is macOS-only in practice.

## Features

- Dark mode with automatic detection
- Task list checkboxes
- Tables, code blocks, blockquotes, strikethrough
- Inline and fenced code with syntax-appropriate styling
- TextBundle support

## Building

Requires Xcode 16.2+ and Swift 6.0.

```
cd App
xcodebuild build -scheme MarkdownQuickLook -destination 'generic/platform=macOS'
xcodebuild build -scheme MarkdownQuickLook -destination 'generic/platform=iOS'
```

## Rendering

Uses [swift-markdown](https://github.com/swiftlang/swift-markdown) to parse Markdown into an AST, then a custom `MarkupVisitor` converts it to styled HTML rendered in a WKWebView. Colors and typography follow GitHub's style conventions.
