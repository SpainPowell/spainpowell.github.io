// Secondary "swell" mark: three ocean contours + node riding the crest.
// At <=16px render only two lines and no node (see favicon.svg).
export function SwellMark({ size = 32, node = 'var(--clay)' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" fill="none" aria-hidden="true">
      <path d="M12 24 Q32 12 52 24" stroke="currentColor" strokeWidth="5" strokeLinecap="round" />
      <path d="M12 37 Q32 25 52 37" stroke="currentColor" strokeWidth="5" strokeLinecap="round" />
      <path d="M12 50 Q32 38 52 50" stroke="currentColor" strokeWidth="5" strokeLinecap="round" />
      <circle cx="47" cy="20" r="4.5" fill={node} />
    </svg>
  );
}
