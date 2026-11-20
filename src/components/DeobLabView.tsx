import { useState } from 'react';
import { Play, RotateCcw, Copy, Check } from 'lucide-react';
import type { LolDecodeResult, WadLiftResult, WeAreDevsDecodeResult } from '../types';

interface DeobLabViewProps {
  samplePayloads: {
    lolSample: string;
    weAreDevsSample: string;
    foldedLuaSnippet: string;
  } | null;
}

type AnalyzerMode = 'wad' | 'lol' | 'wearedevs';

export function DeobLabView({ samplePayloads }: DeobLabViewProps) {
  const [mode, setMode] = useState<AnalyzerMode>('wad');
  const [source, setSource] = useState<string>(samplePayloads?.weAreDevsSample || '');
  const [running, setRunning] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [wadResult, setWadResult] = useState<WadLiftResult | null>(null);
  const [lolResult, setLolResult] = useState<LolDecodeResult | null>(null);
  const [weAreDevsResult, setWeAreDevsResult] = useState<WeAreDevsDecodeResult | null>(null);
  const [copied, setCopied] = useState(false);

  const loadSample = (targetMode: AnalyzerMode) => {
    setMode(targetMode);
    setError(null);
    if (!samplePayloads) return;
    if (targetMode === 'lol') {
      setSource(samplePayloads.lolSample);
    } else {
      setSource(samplePayloads.weAreDevsSample);
    }
  };

  const runAnalysis = async () => {
    if (!source.trim()) {
      setError('Paste a Lua payload or load one of the built-in samples first.');
      return;
    }
    setRunning(true);
    setError(null);
    try {
      const endpoint =
        mode === 'wad'
          ? '/api/analyze/wad'
          : mode === 'lol'
          ? '/api/analyze/lol'
          : '/api/analyze/wearedevs';
      const resp = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ source }),
      });
      const json = await resp.json();
      if (!resp.ok) {
        throw new Error(json.error || 'Analysis failed');
      }
      if (mode === 'wad') setWadResult(json);
      else if (mode === 'lol') setLolResult(json);
      else setWeAreDevsResult(json);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unexpected error');
    } finally {
      setRunning(false);
    }
  };

  const handleCopyOutput = (text: string) => {
    navigator.clipboard?.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 1500);
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold text-slate-900">Deobfuscation &amp; Constant-Folding Lab</h1>
          <p className="text-sm text-slate-600 mt-1">
            TypeScript ports of <span className="font-mono text-slate-800">deob/wad_lift.py</span>,{' '}
            <span className="font-mono text-slate-800">deob/deob_lol.py</span>, and{' '}
            <span className="font-mono text-slate-800">deob/deob_wearedevs.py</span> running server-side.
          </p>
        </div>

        <div className="flex items-center gap-1 p-1 bg-slate-100 rounded-lg self-start">
          <button
            onClick={() => setMode('wad')}
            className={`px-3 py-1.5 text-xs font-medium rounded-md transition-colors whitespace-nowrap shrink-0 cursor-pointer ${
              mode === 'wad' ? 'bg-white text-slate-900 shadow-xs' : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            WAD Lifter &amp; Folder
          </button>
          <button
            onClick={() => setMode('wearedevs')}
            className={`px-3 py-1.5 text-xs font-medium rounded-md transition-colors whitespace-nowrap shrink-0 cursor-pointer ${
              mode === 'wearedevs' ? 'bg-white text-slate-900 shadow-xs' : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            WeAreDevs Base64
          </button>
          <button
            onClick={() => setMode('lol')}
            className={`px-3 py-1.5 text-xs font-medium rounded-md transition-colors whitespace-nowrap shrink-0 cursor-pointer ${
              mode === 'lol' ? 'bg-white text-slate-900 shadow-xs' : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            LOL! Hex + RLE
          </button>
        </div>
      </div>

      {/* Input & Controls */}
      <div className="rounded-lg border border-slate-200 bg-white p-5 space-y-4">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div className="flex flex-wrap items-center gap-2">
            <span className="text-xs font-medium text-slate-500">Load Sample:</span>
            <button
              onClick={() => loadSample('wad')}
              className="px-2.5 py-1 text-xs font-medium text-slate-700 bg-slate-100 hover:bg-slate-200 rounded-md transition-colors cursor-pointer"
            >
              WeAreDevs + Arithmetic Fold
            </button>
            <button
              onClick={() => loadSample('lol')}
              className="px-2.5 py-1 text-xs font-medium text-slate-700 bg-slate-100 hover:bg-slate-200 rounded-md transition-colors cursor-pointer"
            >
              LOL! Hex/RLE Container
            </button>
            {samplePayloads?.foldedLuaSnippet && (
              <button
                onClick={() => {
                  setMode('wad');
                  setSource(samplePayloads.foldedLuaSnippet);
                  setError(null);
                }}
                className="px-2.5 py-1 text-xs font-medium text-slate-700 bg-slate-100 hover:bg-slate-200 rounded-md transition-colors cursor-pointer"
              >
                AV0X Folded Dispatch Slice
              </button>
            )}
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={() => {
                setSource('');
                setError(null);
              }}
              className="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-slate-600 hover:text-slate-900 border border-slate-200 rounded-md transition-colors cursor-pointer"
            >
              <RotateCcw className="w-3.5 h-3.5" />
              Clear
            </button>
            <button
              onClick={runAnalysis}
              disabled={running}
              className="inline-flex items-center gap-1.5 px-4 py-1.5 text-xs font-medium text-white bg-teal-700 hover:bg-teal-800 disabled:opacity-50 rounded-md transition-colors cursor-pointer"
            >
              <Play className="w-3.5 h-3.5" />
              {running ? 'Analyzing...' : 'Run Analyzer'}
            </button>
          </div>
        </div>

        <textarea
          value={source}
          onChange={(e) => setSource(e.target.value)}
          rows={9}
          spellCheck={false}
          placeholder="Paste Lua source, local W={...} string table, or LOL!... hex+RLE payload..."
          className="w-full rounded-md border border-slate-200 bg-slate-50 p-3 font-mono text-xs text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-600 focus:border-transparent"
        />

        {error && (
          <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-700">
            Error: {error}
          </div>
        )}
      </div>

      {/* Results Output */}
      {mode === 'wad' && wadResult && (
        <div className="space-y-4">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div className="rounded-lg border border-slate-200 bg-white p-4">
              <div className="text-xs text-slate-500">Protection Signatures</div>
              <div className="mt-1 text-sm font-semibold text-slate-900">{wadResult.protection.join(', ')}</div>
            </div>
            <div className="rounded-lg border border-slate-200 bg-white p-4">
              <div className="text-xs text-slate-500">Expressions Folded</div>
              <div className="mt-1 text-lg font-bold font-mono text-teal-700 tabular-nums">
                {wadResult.constantFolding.foldedExpressions}
              </div>
              <div className="text-xs text-slate-500 tabular-nums">
                {(wadResult.constantFolding.reductionRatio * 100).toFixed(2)}% size reduction
              </div>
            </div>
            <div className="rounded-lg border border-slate-200 bg-white p-4">
              <div className="text-xs text-slate-500">String Table Entropy</div>
              <div className="mt-1 text-lg font-bold font-mono text-slate-900 tabular-nums">
                {wadResult.stringTable.entropy}
              </div>
              <div className="text-xs text-slate-500 tabular-nums">
                {wadResult.stringTable.entries} entries · {wadResult.stringTable.decodedBytes} B
              </div>
            </div>
            <div className="rounded-lg border border-slate-200 bg-white p-4">
              <div className="text-xs text-slate-500">Parenthesis Balance</div>
              <div className="mt-1 text-lg font-bold font-mono text-slate-900 tabular-nums">
                {wadResult.parenBalance}
              </div>
              <div className="text-xs text-slate-500 tabular-nums">
                Periodicity width: {wadResult.structure.candidateInstructionWidth ?? 'n/a'}
              </div>
            </div>
          </div>

          <div className="rounded-lg border border-slate-200 bg-white p-5 space-y-3">
            <div className="flex items-center justify-between">
              <h3 className="text-sm font-semibold text-slate-900">Constant-Folded Lua Output</h3>
              <button
                onClick={() => handleCopyOutput(wadResult.foldedPreview)}
                className="inline-flex items-center gap-1.5 text-xs font-medium text-slate-600 hover:text-slate-900 cursor-pointer"
              >
                {copied ? <Check className="w-3.5 h-3.5 text-emerald-600" /> : <Copy className="w-3.5 h-3.5" />}
                {copied ? 'Copied' : 'Copy Output'}
              </button>
            </div>
            <pre className="rounded-md border border-slate-200 bg-slate-50 p-3 font-mono text-xs text-slate-800 overflow-x-auto max-h-80 overflow-y-auto whitespace-pre-wrap">
              {wadResult.foldedPreview}
            </pre>
          </div>
        </div>
      )}

      {mode === 'wearedevs' && weAreDevsResult && (
        <div className="rounded-lg border border-slate-200 bg-white p-5 space-y-4">
          <div className="flex flex-wrap items-center gap-6 text-xs text-slate-600 border-b border-slate-100 pb-3">
            <span>
              Source: <strong className="font-mono text-slate-900 tabular-nums">{weAreDevsResult.sourceBytes} B</strong>
            </span>
            <span>
              Alphabet Entries: <strong className="font-mono text-slate-900 tabular-nums">{weAreDevsResult.alphabetSize}/64</strong>
            </span>
            <span>
              Table Literals: <strong className="font-mono text-slate-900 tabular-nums">{weAreDevsResult.tableLiterals}</strong>
            </span>
            <span>
              Decoded Unique: <strong className="font-mono text-teal-700 tabular-nums">{weAreDevsResult.uniqueStrings.length}</strong>
            </span>
          </div>
          <div className="space-y-1.5">
            <h3 className="text-sm font-semibold text-slate-900">Decoded Constants</h3>
            {weAreDevsResult.printableStrings.length === 0 ? (
              <p className="text-xs text-slate-500">No printable ASCII strings decoded.</p>
            ) : (
              <div className="divide-y divide-slate-100 border border-slate-200 rounded-md">
                {weAreDevsResult.printableStrings.map((str, i) => (
                  <div key={i} className="px-3 py-2 flex items-center gap-3 text-xs font-mono">
                    <span className="text-slate-400 w-8 tabular-nums">{i + 1}</span>
                    <span className="text-slate-900 break-all">{str}</span>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      )}

      {mode === 'lol' && lolResult && (
        <div className="rounded-lg border border-slate-200 bg-white p-5 space-y-4">
          <div className="flex flex-wrap items-center gap-6 text-xs text-slate-600 border-b border-slate-100 pb-3">
            <span>
              Raw Payload: <strong className="font-mono text-slate-900 tabular-nums">{lolResult.rawChars} chars</strong>
            </span>
            <span>
              Decoded Container: <strong className="font-mono text-slate-900 tabular-nums">{lolResult.decodedBytes} bytes</strong>
            </span>
            <span>
              Unique Strings: <strong className="font-mono text-teal-700 tabular-nums">{lolResult.uniqueStrings.length}</strong>
            </span>
            <span>
              Network / API Matches: <strong className="font-mono text-amber-700 tabular-nums">{lolResult.networkMatches.length}</strong>
            </span>
          </div>
          <div>
            <div className="text-xs font-medium text-slate-500 mb-1.5">Hex Dump Preview (first 96 bytes)</div>
            <pre className="rounded-md border border-slate-200 bg-slate-50 p-3 font-mono text-xs text-slate-700 overflow-x-auto">
              {lolResult.hexPreview || '(empty)'}
            </pre>
          </div>
          <div>
            <div className="text-xs font-medium text-slate-500 mb-1.5">Extracted Printable Constants</div>
            <div className="divide-y divide-slate-100 border border-slate-200 rounded-md">
              {lolResult.uniqueStrings.map((str, i) => (
                <div key={i} className="px-3 py-2 flex items-center justify-between gap-4 text-xs font-mono">
                  <span className="text-slate-900 break-all">{str}</span>
                  {lolResult.networkMatches.includes(str) && (
                    <span className="text-amber-700 shrink-0 font-sans font-medium">API / Network</span>
                  )}
                </div>
              ))}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
