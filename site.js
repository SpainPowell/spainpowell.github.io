(() => {
  const root = document.documentElement;
  const toggle = document.querySelector('[data-theme-toggle]');
  const label = document.querySelector('[data-theme-label]');
  let storedTheme = null;
  try {
    storedTheme = window.localStorage.getItem('spain-theme');
  } catch {
    storedTheme = null;
  }
  const systemTheme = window.matchMedia?.('(prefers-color-scheme: light)').matches ? 'light' : 'dark';

  const setTheme = (theme) => {
    root.dataset.theme = theme;
    const isLight = theme === 'light';
    toggle?.setAttribute('aria-pressed', String(isLight));
    toggle?.setAttribute('aria-label', isLight ? 'Switch to dark mode' : 'Switch to light mode');
    if (label) label.textContent = isLight ? 'Dark mode' : 'Light mode';
    document.querySelector('meta[name="theme-color"]')?.setAttribute('content', isLight ? '#F7EEDF' : '#100D0A');
  };

  setTheme(storedTheme || systemTheme);

  toggle?.addEventListener('click', () => {
    const nextTheme = root.dataset.theme === 'light' ? 'dark' : 'light';
    try {
      window.localStorage.setItem('spain-theme', nextTheme);
    } catch {
      // Theme still changes for this visit when storage is unavailable.
    }
    setTheme(nextTheme);
  });
})();
