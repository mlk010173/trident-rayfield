export interface WadLiftReport {
  bytes: number;
  protection: string[];
  stringTable: {
    entries: number;
    decodedBytes: number;
    entropy: number;
    printableRatio: number;
  };
  structure: {
    anonymousFunctions: number;
    candidateInstructionWidth: number | null;
    periodicity: number;
  };
  constantFolding: {
    foldedExpressions: number;
    bytesBefore: number;
    bytesAfter: number;
    reductionRatio: number;
  };
  parenBalance: number;
  dispatchSlices: string[];
  sampleStrings: string[];
  foldedPreview: string;
}

export interface LolDecodeReport {
  rawChars: number;
  decodedBytes: number;
  hexPreview: string;
  uniqueStrings: string[];
  networkMatches: string[];
}

export interface WeAreDevsDecodeReport {
  sourceBytes: number;
  tableLiterals: number;
  alphabetSize: number;
  uniqueStrings: string[];
  printableStrings: string[];
}

export function detectProtection(text: string): string[] {
  const sig: string[] = [];
  if (text.includes('wearedevs.net/obfuscator')) sig.push('WeAreDevs v1.0.0');
  if (text.includes('LOL!')) sig.push('LOL-VM');
  if (/MoonSec/i.test(text)) sig.push('MoonSec');
  if (/Luraph/i.test(text)) sig.push('Luraph');
  if (text.startsWith('\x1bLua') || text.startsWith('RBM')) sig.push('Bytecode');
  return sig.length > 0 ? sig : ['Unknown / Plain Luau'];
}

export function extractLuaTable(source: string, marker = 'local W={'): string | null {
  const markerIdx = source.indexOf(marker);
  if (markerIdx < 0) return null;
  const braceIdx = source.indexOf('{', markerIdx);
  if (braceIdx < 0) return null;
  let depth = 0;
  let inString: '"' | "'" | null = null;
  let escaped = false;
  for (let k = braceIdx; k < source.length; k++) {
    const ch = source[k];
    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (ch === '\\') {
        escaped = true;
      } else if (ch === inString) {
        inString = null;
      }
      continue;
    }
    if (ch === '"' || ch === "'") {
      inString = ch;
      continue;
    }
    if (ch === '{') depth++;
    else if (ch === '}') {
      depth--;
      if (depth === 0) return source.slice(braceIdx, k + 1);
    }
  }
  return null;
}

export function luaUnescapeBytes(text: string): Uint8Array {
  const out: number[] = [];
  let i = 0;
  const mapping: Record<string, number> = {
    n: 10,
    t: 9,
    r: 13,
    '\\': 92,
    '"': 34,
    "'": 39,
    a: 7,
    b: 8,
    f: 12,
    v: 11,
  };
  while (i < text.length) {
    const c = text[i];
    if (c === '\\' && i + 1 < text.length) {
      const decMatch = /^\\(\d{1,3})/.exec(text.slice(i));
      if (decMatch) {
        out.push(parseInt(decMatch[1], 10) & 0xff);
        i += 1 + decMatch[1].length;
        continue;
      }
      const nxt = text[i + 1];
      if (nxt in mapping) {
        out.push(mapping[nxt]);
        i += 2;
        continue;
      }
      out.push(nxt.charCodeAt(0) & 0xff);
      i += 2;
      continue;
    }
    out.push(c.charCodeAt(0) & 0xff);
    i += 1;
  }
  return Uint8Array.from(out);
}

export function luaUnescapeString(text: string): string {
  const bytes = luaUnescapeBytes(text);
  let out = '';
  for (let i = 0; i < bytes.length; i++) {
    out += String.fromCharCode(bytes[i]);
  }
  return out;
}

function extractStringLiterals(tableBody: string): string[] {
  const matches: string[] = [];
  const regex = /"((?:[^"\\]|\\.)*)"/g;
  let m: RegExpExecArray | null;
  while ((m = regex.exec(tableBody)) !== null) {
    matches.push(m[1]);
  }
  return matches;
}

function shannonEntropy(data: Uint8Array): number {
  if (data.length === 0) return 0;
  const counts = new Map<number, number>();
  for (let i = 0; i < data.length; i++) {
    counts.set(data[i], (counts.get(data[i]) ?? 0) + 1);
  }
  let ent = 0;
  for (const v of counts.values()) {
    const p = v / data.length;
    ent -= p * Math.log2(p);
  }
  return Number(ent.toFixed(3));
}

function instructionWidth(blob: Uint8Array): { width: number | null; score: number } {
  let best = 0;
  let bestW: number | null = null;
  const sampleLen = Math.min(blob.length, 20000);
  for (const w of [3, 4, 5, 8]) {
    if (sampleLen <= w) continue;
    let hits = 0;
    for (let i = 0; i < sampleLen - w; i++) {
      if (blob[i] === blob[i + w]) hits++;
    }
    const score = hits / Math.max(1, sampleLen - w);
    if (score > best) {
      best = score;
      bestW = w;
    }
  }
  return { width: bestW, score: Number(best.toFixed(3)) };
}

export function foldConstants(text: string, maxPasses = 6): { folded: string; folds: number } {
  const numOp = /(?<![\w.])(-?\d+)\s*([+\-])\s*(-?\d+)(?![\w.])/g;
  let total = 0;
  let current = text;
  for (let pass = 0; pass < maxPasses; pass++) {
    let count = 0;
    const next = current.replace(numOp, (_full, aStr, op, bStr) => {
      const a = parseInt(aStr, 10);
      const b = parseInt(bStr, 10);
      if (!Number.isSafeInteger(a) || !Number.isSafeInteger(b)) return _full;
      const val = op === '+' ? a + b : a - b;
      count++;
      return val >= 0 ? String(val) : `(0${val})`;
    });
    total += count;
    if (count === 0 || next === current) break;
    current = next;
  }
  return { folded: current, folds: total };
}

export function analyzeWadLift(source: string): WadLiftReport {
  const table = extractLuaTable(source, 'local W={') ?? extractLuaTable(source, 'local W = {');
  const rawLiterals = table ? extractStringLiterals(table) : [];
  const byteChunks = rawLiterals.map((lit) => luaUnescapeBytes(lit));
  const totalBytes = byteChunks.reduce((acc, chunk) => acc + chunk.length, 0);
  const blob = new Uint8Array(totalBytes);
  let offset = 0;
  for (const chunk of byteChunks) {
    blob.set(chunk, offset);
    offset += chunk.length;
  }

  let printableCount = 0;
  for (let i = 0; i < blob.length; i++) {
    if (blob[i] >= 32 && blob[i] < 127) printableCount++;
  }
  const printableRatio = Number((printableCount / Math.max(1, blob.length)).toFixed(3));
  const { width, score } = instructionWidth(blob);
  const { folded, folds } = foldConstants(source);

  let openParens = 0;
  let closeParens = 0;
  for (let i = 0; i < folded.length; i++) {
    if (folded[i] === '(') openParens++;
    else if (folded[i] === ')') closeParens++;
  }

  const dispatchSlices: string[] = [];
  const dispatchRegex = /while z do/g;
  let dm: RegExpExecArray | null;
  while ((dm = dispatchRegex.exec(folded)) !== null && dispatchSlices.length < 3) {
    dispatchSlices.push(folded.slice(dm.index, dm.index + 260));
  }

  const sampleStrings = byteChunks
    .slice(0, 12)
    .map((chunk) => Array.from(chunk).map((b) => String.fromCharCode(b)).join(''))
    .filter(Boolean);

  const anonCount = (source.match(/function\(/g) ?? []).length;

  return {
    bytes: source.length,
    protection: detectProtection(source),
    stringTable: {
      entries: byteChunks.length,
      decodedBytes: blob.length,
      entropy: shannonEntropy(blob),
      printableRatio,
    },
    structure: {
      anonymousFunctions: anonCount,
      candidateInstructionWidth: width,
      periodicity: score,
    },
    constantFolding: {
      foldedExpressions: folds,
      bytesBefore: source.length,
      bytesAfter: folded.length,
      reductionRatio: Number((1 - folded.length / Math.max(1, source.length)).toFixed(4)),
    },
    parenBalance: openParens - closeParens,
    dispatchSlices,
    sampleStrings,
    foldedPreview: folded.slice(0, 16000),
  };
}

export function analyzeLolVm(source: string): LolDecodeReport {
  let raw = source.trim();
  if (!raw.startsWith('LOL!')) {
    const candidates = extractStringLiterals(source).sort((a, b) => b.length - a.length);
    if (candidates.length === 0) {
      throw new Error('No quoted string literal or LOL! payload found in input.');
    }
    raw = candidates[0];
  }

  const body = raw.startsWith('LOL!') ? raw.slice(4) : raw;
  const out: number[] = [];
  let pend: number | null = null;
  let i = 0;

  while (i + 1 < body.length) {
    const ch = body.slice(i, i + 2);
    if (ch[1] === 'O') {
      const rep = parseInt(ch[0], 10);
      if (!Number.isNaN(rep)) pend = rep;
    } else if (/^[0-9a-fA-F]{2}$/.test(ch)) {
      const b = parseInt(ch, 16);
      const count = pend && pend > 0 ? pend : 1;
      for (let r = 0; r < count; r++) out.push(b);
      pend = null;
    }
    i += 2;
  }

  const bytes = Uint8Array.from(out);
  const asciiText = Array.from(bytes)
    .map((b) => String.fromCharCode(b))
    .join('');

  const seen = new Set<string>();
  const uniqueStrings: string[] = [];
  const strRegex = /[\x20-\x7e]{4,}/g;
  let m: RegExpExecArray | null;
  while ((m = strRegex.exec(asciiText)) !== null) {
    if (!seen.has(m[0])) {
      seen.add(m[0]);
      uniqueStrings.push(m[0]);
    }
  }

  const netRegex =
    /(FireServer|InvokeServer|RemoteEvent|RemoteFunction|HttpGet|http|TCP|Shared\.entities|EntityMap|LocalCharacter|hookfunction|getgc|ProximityPrompt|Hitbox|Silent|aimbot|killaura|esp)/i;
  const networkMatches = uniqueStrings.filter((s) => netRegex.test(s));

  const hexPreview = Array.from(bytes.slice(0, 96))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join(' ');

  return {
    rawChars: raw.length,
    decodedBytes: bytes.length,
    hexPreview,
    uniqueStrings,
    networkMatches,
  };
}

// Safe arithmetic expression parser for WeAreDevs alphabet values (no eval)
function evalSafeIntExpr(expr: string): number {
  const cleaned = expr.replace(/\s+/g, '').replace(/\+-/g, '-').replace(/--/g, '+');
  if (!/^[0-9+\-*/().]+$/.test(cleaned)) {
    throw new Error(`Unsafe expression: ${expr}`);
  }
  let pos = 0;

  function parseExpression(): number {
    let left = parseTerm();
    while (pos < cleaned.length && (cleaned[pos] === '+' || cleaned[pos] === '-')) {
      const op = cleaned[pos++];
      const right = parseTerm();
      left = op === '+' ? left + right : left - right;
    }
    return left;
  }

  function parseTerm(): number {
    let left = parseFactor();
    while (pos < cleaned.length && (cleaned[pos] === '*' || cleaned[pos] === '/')) {
      const op = cleaned[pos++];
      const right = parseFactor();
      left = op === '*' ? left * right : Math.trunc(left / right);
    }
    return left;
  }

  function parseFactor(): number {
    if (cleaned[pos] === '+') {
      pos++;
      return parseFactor();
    }
    if (cleaned[pos] === '-') {
      pos++;
      return -parseFactor();
    }
    if (cleaned[pos] === '(') {
      pos++;
      const val = parseExpression();
      if (cleaned[pos] !== ')') throw new Error('Unmatched parenthesis');
      pos++;
      return val;
    }
    const numMatch = /^\d+/.exec(cleaned.slice(pos));
    if (!numMatch) throw new Error(`Unexpected token at ${pos}`);
    pos += numMatch[0].length;
    return parseInt(numMatch[0], 10);
  }

  const result = parseExpression();
  if (pos !== cleaned.length) throw new Error('Trailing characters in expression');
  return Math.trunc(result);
}

function findAlphabet(source: string): Map<string, number> {
  const localTableRegex = /local\s+\w+\s*=\s*\{/g;
  let match: RegExpExecArray | null;
  while ((match = localTableRegex.exec(source)) !== null) {
    const block = extractLuaTable(source.slice(match.index), '{');
    if (!block) continue;
    const alpha = new Map<string, number>();
    const pairRegex = /(?:([A-Za-z_]\w*)|\["\\(\d+)"\])\s*=\s*([0-9+\-*/() ]+)/g;
    let pm: RegExpExecArray | null;
    let valid = true;
    while ((pm = pairRegex.exec(block)) !== null) {
      const key = pm[1] ? pm[1] : String.fromCharCode(parseInt(pm[2], 10));
      try {
        alpha.set(key, evalSafeIntExpr(pm[3]));
      } catch {
        valid = false;
        break;
      }
    }
    if (!valid || alpha.size !== 64) continue;
    const vals = new Set(alpha.values());
    if (vals.size === 64) {
      let allInRange = true;
      for (const v of vals) {
        if (v < 0 || v > 63) {
          allInRange = false;
          break;
        }
      }
      if (allInRange) return alpha;
    }
  }
  throw new Error('Could not locate a 64-entry custom Base64 alphabet table in input.');
}

function decodeCustomBase64(enc: string, alpha: Map<string, number>): string {
  const out: string[] = [];
  let e = 0;
  let d = 0;
  let p = 1;
  const n = enc.length;

  while (p <= n) {
    const c = enc[p - 1];
    const w = alpha.get(c);
    if (w !== undefined) {
      e += w * Math.pow(64, 3 - d);
      d += 1;
      if (d === 4) {
        d = 0;
        out.push(String.fromCharCode(Math.floor(e / 65536)));
        out.push(String.fromCharCode(Math.floor((e % 65536) / 256)));
        out.push(String.fromCharCode(e % 256));
        e = 0;
      }
    } else if (c === '=') {
      out.push(String.fromCharCode(Math.floor(e / 65536)));
      if (p >= n || enc[p] !== '=') {
        out.push(String.fromCharCode(Math.floor((e % 65536) / 256)));
      }
      break;
    }
    p += 1;
  }

  return out.join('');
}

export function analyzeWeAreDevs(source: string): WeAreDevsDecodeReport {
  const wtbl = extractLuaTable(source, 'local W={') ?? extractLuaTable(source, 'local W = {');
  if (!wtbl) {
    throw new Error('String table `local W={...}` not found in input.');
  }
  const alpha = findAlphabet(source);
  const lits = extractStringLiterals(wtbl);
  const seen = new Set<string>();
  const uniqueStrings: string[] = [];

  for (const lit of lits) {
    try {
      const txt = decodeCustomBase64(luaUnescapeString(lit), alpha);
      if (txt && !seen.has(txt)) {
        seen.add(txt);
        uniqueStrings.push(txt);
      }
    } catch {
      // skip malformed literal
    }
  }

  const printableStrings = uniqueStrings.filter((s) => /^[\x20-\x7e]{3,}$/.test(s));

  return {
    sourceBytes: source.length,
    tableLiterals: lits.length,
    alphabetSize: alpha.size,
    uniqueStrings,
    printableStrings,
  };
}
