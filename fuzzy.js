// Minimal fuzzy subsequence matcher for launcher search.
// Supports non-consecutive matches: e.g. "ovhharbwname" matches
// "ovh.com/Hexagonal/harbor/web/my-login-name".

function normalizeForMatch(s) {
  if (!s) return "";
  return String(s).toLowerCase().replace(/[^a-z0-9]/g, "");
}

// Returns a number score (higher is better) or null if no match.
function subsequenceScore(needle, haystack) {
  if (!needle) return 0;
  if (!haystack) return null;

  let pos = -1;
  let start = -1;
  let gaps = 0;
  let contiguous = 0;
  let bestContiguous = 0;

  for (let i = 0; i < needle.length; i++) {
    const ch = needle[i];
    const next = haystack.indexOf(ch, pos + 1);
    if (next < 0) return null;

    if (start < 0) start = next;

    if (pos >= 0) {
      const gap = next - pos - 1;
      gaps += gap;
      if (gap === 0) contiguous += 1;
      else {
        if (contiguous > bestContiguous) bestContiguous = contiguous;
        contiguous = 0;
      }
    }

    pos = next;
  }

  if (contiguous > bestContiguous) bestContiguous = contiguous;

  // Scoring: prefer earlier matches, fewer gaps, and more contiguous runs.
  // Also mildly prefer shorter candidates (after normalization).
  let score = 1000;
  score -= start * 3;
  score -= gaps * 2;
  score += bestContiguous * 6;
  score -= (haystack.length - needle.length);
  return score;
}

// Multi-token support:
// - Split query on whitespace
// - Each token must match (AND)
// - Total score = sum of token scores
function fuzzyScore(query, candidate) {
  const trimmed = (query || "").trim();
  if (!trimmed) return null;

  const qTokens = trimmed.split(/\s+/g).filter(Boolean).map(normalizeForMatch);
  const cNorm = normalizeForMatch(candidate);
  if (!cNorm) return null;

  let total = 0;
  for (const q of qTokens) {
    if (!q) continue;
    const s = subsequenceScore(q, cNorm);
    if (s === null) return null;
    total += s;
  }
  return total;
}
