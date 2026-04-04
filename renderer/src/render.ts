import markdownit from 'markdown-it';
import anchor from 'markdown-it-anchor';
import mila from 'markdown-it-link-attributes';
import footnote from 'markdown-it-footnote';
import tasklist from 'markdown-it-task-lists';
import githubAlerts from 'markdown-it-github-alerts';
import hljs from 'markdown-it-highlightjs';
import katexPlugin from './katex-plugin';

import { createFrontMatterPlugin } from './frontMatter';
import { coreCss, previewThemeCss, alertsCss, hljsCss, codeCopyCss } from './styling';
import type { ColorScheme } from './styling';

import katexCss from '../styles/katex.css?raw';

const THEME = 'github';
const COLOR_SCHEME: ColorScheme = 'auto';

// Create the markdown-it instance
const mdit = markdownit('default', {
  html: true,
  breaks: true,
  linkify: true,
});

// Front matter (synchronous in our version)
const frontMatterPlugin = createFrontMatterPlugin(mdit);
mdit.use(frontMatterPlugin);

// Link attributes
mdit.use(anchor);
mdit.use(mila, {
  matcher: (href: string) => !href.startsWith('#'),
  attrs: {
    target: '_blank',
    rel: 'noopener',
  },
});

// Extended syntaxes
mdit.use(footnote);
mdit.use(tasklist);
mdit.use(githubAlerts);

// Highlight.js
mdit.use(hljs, { auto: false });

// KaTeX
mdit.use(katexPlugin);

// Block types that get line info attributes
const blockTypes = new Set([
  'paragraph_open',
  'heading_open',
  'blockquote_open',
  'list_item_open',
  'bullet_list_open',
  'ordered_list_open',
  'fence',
  'code_block',
  'table_open',
  'html_block',
  'front_matter',
]);

// Mermaid fence rendering
const renderFence = mdit.renderer.rules.fence;
mdit.renderer.rules.fence = (tokens, idx, options, env, self) => {
  const token = tokens[idx];
  const code = token.content.trim();
  const lang = token.info.trim();

  token.attrSet('data-code', code + '\n');

  if (lang === 'mermaid') {
    const dataCode = self.renderAttrs(token);
    const escapedCode = mdit.utils.escapeHtml(code);
    return `<div class="mermaid"${dataCode}>${escapedCode}</div>`;
  }

  if (renderFence !== undefined) {
    return renderFence(tokens, idx, options, env, self);
  }

  return `<pre><code class="language-${lang}">${mdit.utils.escapeHtml(code)}</code></pre>`;
};

// Copy button for code blocks
for (const type of ['fence', 'code_block']) {
  const renderCode = mdit.renderer.rules[type];
  mdit.renderer.rules[type] = (tokens, idx, options, env, self) => {
    const codeBlock = renderCode === undefined ? self.renderToken(tokens, idx, options) : renderCode(tokens, idx, options, env, self);
    return `
    <div class="code-copy-wrapper" onmouseenter="this.querySelector('.code-copy-button').style.opacity='1'" onmouseleave="this.querySelector('.code-copy-button').style.opacity='0'">
      ${codeBlock}
      <button title="Copy Code" aria-label="Copy Code" class="code-copy-button" onclick="navigator.clipboard.writeText(this.previousElementSibling.dataset.code ?? this.previousElementSibling.innerText); this.style.opacity='0'">
        <svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16">
          <path fill="currentColor" d="M0 6.75C0 5.784.784 5 1.75 5h1.5a.75.75 0 0 1 0 1.5h-1.5a.25.25 0 0 0-.25.25v7.5c0 .138.112.25.25.25h7.5a.25.25 0 0 0 .25-.25v-1.5a.75.75 0 0 1 1.5 0v1.5A1.75 1.75 0 0 1 9.25 16h-7.5A1.75 1.75 0 0 1 0 14.25Z"></path>
          <path fill="currentColor" d="M5 1.75C5 .784 5.784 0 6.75 0h7.5C15.216 0 16 .784 16 1.75v7.5A1.75 1.75 0 0 1 14.25 11h-7.5A1.75 1.75 0 0 1 5 9.25Zm1.75-.25a.25.25 0 0 0-.25.25v7.5c0 .138.112.25.25.25h7.5a.25.25 0 0 0 .25-.25v-7.5a.25.25 0 0 0-.25-.25Z"></path>
        </svg>
      </button>
    </div>`;
  };
}

export function renderMarkdown(markdown: string): string {
  return mdit.render(markdown);
}

export function injectStyles(): void {
  const sheets = [
    coreCss(THEME, COLOR_SCHEME),
    previewThemeCss(THEME, COLOR_SCHEME),
    alertsCss(COLOR_SCHEME),
    codeCopyCss(COLOR_SCHEME),
    hljsCss(COLOR_SCHEME),
    katexCss,
  ];

  for (const css of sheets) {
    const style = document.createElement('style');
    style.textContent = css;
    document.head.appendChild(style);
  }
}
