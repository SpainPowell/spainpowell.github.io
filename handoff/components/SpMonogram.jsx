// Primary SP route monogram. Inherits stroke color from CSS 'color'.
export function SpMonogram({ size = 34, node = 'var(--clay)' }) {
  return (
    <svg width={size} height={size * 52 / 70} viewBox="0 0 70 52" fill="none" aria-label="Spain Powell">
      <path d="M34 10 L10 10 L10 26 L34 26 L34 42 L12 42" stroke="currentColor" strokeWidth="6" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M44 42 L44 10 L60 10 L60 26 L44 26" stroke="currentColor" strokeWidth="6" strokeLinecap="round" strokeLinejoin="round" />
      <circle cx="12" cy="42" r="4" fill={node} />
    </svg>
  );
}
