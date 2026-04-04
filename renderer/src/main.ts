import { renderMarkdown, injectStyles } from './render';

// Read markdown from the hidden source element populated by the QuickLook extension.
const sourceElement = document.getElementById('markdown-source');
if (sourceElement) {
  const markdown = sourceElement.textContent ?? '';
  sourceElement.remove();

  // Inject all CSS into <head>
  injectStyles();

  // Render markdown and insert into body
  const container = document.createElement('div');
  container.className = 'markdown-body';
  container.innerHTML = renderMarkdown(markdown);
  document.body.appendChild(container);

  // Initialize mermaid if any diagrams are present (bundled, no CDN)
  if (document.querySelector('.mermaid')) {
    import('mermaid').then(({ default: mermaid }) => {
      const isDarkMode = matchMedia('(prefers-color-scheme: dark)').matches;
      mermaid.initialize({ theme: isDarkMode ? 'dark' : undefined });
      mermaid.run({ querySelector: '.mermaid' });
    });
  }
}
