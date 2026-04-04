import { renderMarkdown, assembleHtml } from './render';

// The native code injects markdown by replacing this placeholder in the built HTML.
const PLACEHOLDER = '<!--MARKDOWN_SOURCE-->';

// Read markdown from the hidden source element injected by the QuickLook extension.
const sourceElement = document.getElementById('markdown-source');
if (sourceElement) {
  const markdown = sourceElement.textContent ?? '';
  const rendered = renderMarkdown(markdown);
  const html = assembleHtml(rendered);

  // Replace the entire document with the rendered output.
  document.open();
  document.write(html);
  document.close();
}
