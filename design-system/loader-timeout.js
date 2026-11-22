// If the 3D view can't start, say so instead of hanging on the loader.
setTimeout(() => {
  const l = document.getElementById('loader');
  if (l && !l.classList.contains('done')) l.textContent = 'Could not load the 3D view. Reload to try again.';
}, 12000);
