# duhbinchi.github.io

Projects site for duhbinchi, built with Vite.

```
design-system/        shared tokens (tokens.css), viewer components (viewer.css), loader fallback
index.html, home.css  homepage
rooftop-design/       Rooftop Studio: page, page styles, 3D scene
envy-media-server-case/  Envy Media Server Case: page, page styles, 3D scene, models and print files
```

Project folders hold only their own page, styles, script and the files they serve. Tooling lives at the root.

- `npm install`
- `npm run dev`: local server with reload
- `npm run build`: static site in `dist/`

Pushes to `main` build and deploy through `.github/workflows/deploy.yml`. In **Settings → Pages**, set the source to **GitHub Actions**.
