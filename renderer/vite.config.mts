import { defineConfig } from 'vite';
import { viteSingleFile } from 'vite-plugin-singlefile';
import katexPackage from 'katex/package.json' with { type: 'json' };

export default defineConfig({
  root: '.',
  build: {
    outDir: 'dist',
    emptyOutDir: true,
    rollupOptions: {
      input: 'index.html',
    },
  },
  plugins: [viteSingleFile(), replaceKaTeXFonts()],
});

function replaceKaTeXFonts() {
  return {
    name: 'replace-katex-fonts',
    transform(code: string, id: string) {
      if (id.endsWith('katex.css?raw')) {
        const modified = code.replace(
          /url\(fonts\//g,
          `url(https://cdn.jsdelivr.net/npm/katex@${katexPackage.version}/dist/fonts/`,
        );
        return { code: modified, map: null };
      }
    },
  };
}
