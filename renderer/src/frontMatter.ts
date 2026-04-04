import type MarkdownIt from 'markdown-it';
import extractFrontMatter from 'markdown-it-front-matter';
import { parse as parseYaml } from 'yaml';

function stripQuotes(input: string) {
  if ((input.startsWith('"') && input.endsWith('"')) || (input.startsWith("'") && input.endsWith("'"))) {
    return input.slice(1, -1);
  }
  return input;
}

/**
 * Self-contained markdown-it plugin that extracts YAML front matter
 * and renders it as an HTML table.
 */
export function createFrontMatterPlugin(mdit: MarkdownIt): MarkdownIt.PluginSimple {
  return () => {
    let renderedHtml = '';
    mdit.use(extractFrontMatter, (raw: string) => {
      const metadata = parseFrontMatter(raw);
      if (metadata !== undefined) {
        renderedHtml = renderFrontMatter(metadata, mdit.utils.escapeHtml);
      } else {
        renderedHtml = '';
      }
    });

    mdit.renderer.rules.front_matter = (tokens, idx, _options, _env, self) => {
      if (renderedHtml === '') {
        return '';
      }

      const attrs = self.renderAttrs(tokens[idx]);
      return `<table class="markdown-frontMatter"${attrs}>\n${renderedHtml}\n</table>\n`;
    };
  };
}

function parseFrontMatter(raw: string): Record<string, unknown> | undefined {
  try {
    const parsed: unknown = parseYaml(raw);
    if (parsed !== null && typeof parsed === 'object' && !Array.isArray(parsed)) {
      return parsed as Record<string, unknown>;
    }
  } catch {
    // Silently ignore malformed YAML
  }
  return undefined;
}

function renderFrontMatter(metadata: Record<string, unknown>, escape: (input: string) => string): string {
  const entries = Object.entries(metadata);
  if (entries.length === 0) {
    return '';
  }

  const headers = entries.map(([key]) => `<th scope="col">${escape(key)}</th>`).join('');
  const values = entries.map(([, value]) => `<td>${formatValue(value, escape)}</td>`).join('');
  return `<thead><tr>${headers}</tr></thead>\n<tbody>\n<tr>${values}</tr>\n</tbody>`;
}

function formatValue(value: unknown, escape: (input: string) => string): string {
  if (value === null || value === undefined) {
    return '';
  }

  if (Array.isArray(value)) {
    return value.map(item => formatValue(item, escape)).join(', ');
  }

  if (typeof value === 'object') {
    return escape(JSON.stringify(value));
  }

  return escape(String(value));
}
