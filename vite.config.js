import { defineConfig } from 'vite';
import { resolve } from 'node:path';
import { cpSync, readdirSync } from 'node:fs';

// Each project folder holds only its page, its styles/script and the files it serves.
const projects = ['rooftop-design', 'envy-media-server-case'];
const source = new Set(['index.html', 'main.js', 'style.css', 'README.md']);

// Files the pages fetch or link at runtime (models, STLs, downloads) are not imported,
// so copy them into the build as-is.
const copyProjectFiles = () => ({
  name: 'copy-project-files',
  apply: 'build',
  closeBundle() {
    for (const p of projects)
      for (const f of readdirSync(p))
        if (!source.has(f)) cpSync(resolve(p, f), resolve('dist', p, f), { recursive: true });
  },
});

export default defineConfig({
  build: {
    chunkSizeWarningLimit: 700,
    rollupOptions: {
      output: { manualChunks: id => (id.includes('node_modules/three') ? 'three' : undefined) },
      input: {
        home: resolve('index.html'),
        ...Object.fromEntries(projects.map(p => [p, resolve(p, 'index.html')])),
      },
    },
  },
  plugins: [copyProjectFiles()],
});
