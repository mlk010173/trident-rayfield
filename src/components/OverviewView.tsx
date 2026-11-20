import { useEffect, useState } from 'react';
import { FileText, ShieldAlert, CheckCircle2, AlertTriangle } from 'lucide-react';
import type { OverviewPayload } from '../types';

interface OverviewViewProps {
  data: OverviewPayload | null;
  loading: boolean;
}

export function OverviewView({ data, loading }: OverviewViewProps) {
  const [selectedReportId, setSelectedReportId] = useState<string>('readme');
  const [reportContent, setReportContent] = useState<string>('');
  const [reportMeta, setReportMeta] = useState<{ title: string; subtitle: string } | null>(null);
  const [loadingReport, setLoadingReport] = useState<boolean>(false);

  useEffect(() => {
    let active = true;
    setLoadingReport(true);
    fetch(`/api/reports/${encodeURIComponent(selectedReportId)}`)
      .then((r) => r.json())
      .then((res) => {
        if (!active) return;
        setReportContent(res.content || '');
        setReportMeta({ title: res.title, subtitle: res.subtitle });
      })
      .catch(() => {
        if (active) setReportContent('Failed to load report content.');
      })
      .finally(() => {
        if (active) setLoadingReport(false);
      });
    return () => {
      active = false;
    };
  }, [selectedReportId]);

  if (loading || !data) {
    return (
      <div className="space-y-6">
        <div className="h-24 rounded-lg border border-slate-200 bg-white animate-pulse" />
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {[1, 2, 3, 4].map((i) => (
            <div key={i} className="h-28 rounded-lg border border-slate-200 bg-white animate-pulse" />
          ))}
        </div>
      </div>
    );
  }

  const { overview, reports } = data;
  const { stats, wadLiftReport, callbackCoverage, analysis } = overview;

  return (
    <div className="space-y-8">
      {/* Migration scope notice */}
      <section className="rounded-lg border border-slate-200 bg-white p-6">
        <div className="flex flex-col lg:flex-row lg:items-start lg:justify-between gap-6">
          <div className="max-w-3xl space-y-2">
            <p className="text-xs font-medium text-teal-700">
              Static Migration Summary · Roblox Luau to Node.js Web Workbench
            </p>
            <h1 className="text-2xl font-bold tracking-tight text-slate-900" style={{ textWrap: 'balance' }}>
              Trident Luau Static Analysis &amp; Configuration Workbench
            </h1>
            <p className="text-sm text-slate-600 leading-relaxed">
              This workspace ports the Python static deobfuscation pipelines (<span className="font-mono text-slate-800">wad_lift</span>,{' '}
              <span className="font-mono text-slate-800">deob_lol</span>, <span className="font-mono text-slate-800">deob_wearedevs</span>),
              extracted string corpora, forensic recovery documentation, and the 6-tab UI configuration schema into a Node.js + React application.
              Roblox-engine runtime hooks (<span className="font-mono text-slate-800">Drawing</span>, <span className="font-mono text-slate-800">getgc</span>,{' '}
              <span className="font-mono text-slate-800">hookfunction</span>, and <span className="font-mono text-slate-800">TCP:FireServer</span>) cannot execute in a browser and are intentionally omitted.
            </p>
          </div>
          <div className="shrink-0 grid grid-cols-2 gap-x-6 gap-y-2 text-xs text-slate-600 border-t lg:border-t-0 lg:border-l border-slate-200 pt-4 lg:pt-0 lg:pl-6">
            <div>
              <div className="text-slate-400">Primary Target</div>
              <div className="font-mono font-medium text-slate-900">trident_rayfield.lua</div>
            </div>
            <div>
              <div className="text-slate-400">Obfuscator Analyzed</div>
              <div className="font-mono font-medium text-slate-900">{analysis.protecao?.primaria || 'WeAreDevs v1.0.0'}</div>
            </div>
            <div>
              <div className="text-slate-400">Analyzed Binary</div>
              <div className="font-mono font-medium text-slate-900 tabular-nums">
                {(wadLiftReport.bytes ?? 1119824).toLocaleString()} bytes
              </div>
            </div>
            <div>
              <div className="text-slate-400">Bytecode Present</div>
              <div className="font-medium text-slate-900">
                {analysis.protecao?.bytecode_luau ? 'Yes (Luau)' : 'No (Pure Lua VM)'}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Core Metric Row */}
      <section className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="rounded-lg border border-slate-200 bg-white p-5">
          <div className="text-xs font-medium text-slate-500">Rayfield UI Controls</div>
          <div className="mt-2 text-2xl font-bold text-slate-900 tabular-nums font-mono">
            {stats.rayfieldControls}
          </div>
          <div className="mt-1 text-xs text-slate-500 tabular-nums">
            {stats.rayfieldLines.toLocaleString()} Luau lines · 6 tabs
          </div>
        </div>

        <div className="rounded-lg border border-slate-200 bg-white p-5">
          <div className="text-xs font-medium text-slate-500">AV0X Extracted Strings</div>
          <div className="mt-2 text-2xl font-bold text-slate-900 tabular-nums font-mono">
            {stats.avoxStringsCount.toLocaleString()}
          </div>
          <div className="mt-1 text-xs text-slate-500 tabular-nums">
            {stats.recoveryStringsCount} verified · {stats.v4StringsCount} V4 constants
          </div>
        </div>

        <div className="rounded-lg border border-slate-200 bg-white p-5">
          <div className="text-xs font-medium text-slate-500">Constant Folding Reduction</div>
          <div className="mt-2 text-2xl font-bold text-teal-700 tabular-nums font-mono">
            {((wadLiftReport.dobra_de_constantes?.reducao ?? 0.2081) * 100).toFixed(2)}%
          </div>
          <div className="mt-1 text-xs text-slate-500 tabular-nums">
            {(wadLiftReport.dobra_de_constantes?.expressoes_dobradas ?? 47801).toLocaleString()} expressions folded
          </div>
        </div>

        <div className="rounded-lg border border-slate-200 bg-white p-5">
          <div className="text-xs font-medium text-slate-500">Callback Trace Coverage</div>
          <div className="mt-2 text-2xl font-bold text-slate-900 tabular-nums font-mono">
            {callbackCoverage.callbacks_alcancados ?? 28} / {callbackCoverage.menu_elementos ?? 166}
          </div>
          <div className="mt-1 text-xs text-slate-500 tabular-nums">
            {(callbackCoverage.callbacks_com_corpo_util ?? []).length} callbacks with usable trace body
          </div>
        </div>
      </section>

      {/* Forensic Audit Breakdown */}
      <section className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="rounded-lg border border-slate-200 bg-white p-6 space-y-4">
          <div className="flex items-center justify-between border-b border-slate-100 pb-3">
            <h2 className="text-base font-semibold text-slate-900">WAD Lifter Structural Metrics</h2>
            <span className="text-xs text-slate-500 font-mono">deob/wad_lift_report.json</span>
          </div>
          <dl className="grid grid-cols-2 gap-y-3 gap-x-6 text-sm">
            <div>
              <dt className="text-xs text-slate-500">Decoded Table Bytes</dt>
              <dd className="font-mono font-medium text-slate-900 tabular-nums">
                {(wadLiftReport.tabela_strings?.bytes_decodificados ?? 48952).toLocaleString()} B
              </dd>
            </div>
            <div>
              <dt className="text-xs text-slate-500">Shannon Entropy</dt>
              <dd className="font-mono font-medium text-slate-900 tabular-nums">
                {wadLiftReport.tabela_strings?.entropia ?? 5.845} bits/byte
              </dd>
            </div>
            <div>
              <dt className="text-xs text-slate-500">Printable Ratio</dt>
              <dd className="font-mono font-medium text-slate-900 tabular-nums">
                {((wadLiftReport.tabela_strings?.razao_imprimivel ?? 1) * 100).toFixed(1)}% ASCII
              </dd>
            </div>
            <div>
              <dt className="text-xs text-slate-500">Candidate Instruction Width</dt>
              <dd className="font-mono font-medium text-slate-900 tabular-nums">
                {wadLiftReport.estrutura?.largura_instrucao_candidata ?? 8} bytes (p={wadLiftReport.estrutura?.periodicidade ?? 0.036})
              </dd>
            </div>
            <div>
              <dt className="text-xs text-slate-500">Anonymous Functions</dt>
              <dd className="font-mono font-medium text-slate-900 tabular-nums">
                {wadLiftReport.estrutura?.funcoes_anonimas ?? 31}
              </dd>
            </div>
            <div>
              <dt className="text-xs text-slate-500">Folded Size Delta</dt>
              <dd className="font-mono font-medium text-slate-900 tabular-nums">
                {(wadLiftReport.dobra_de_constantes?.bytes_antes ?? 1119824).toLocaleString()} &rarr;{' '}
                {(wadLiftReport.dobra_de_constantes?.bytes_depois ?? 886777).toLocaleString()} B
              </dd>
            </div>
          </dl>
        </div>

        <div className="rounded-lg border border-slate-200 bg-white p-6 space-y-4">
          <div className="flex items-center justify-between border-b border-slate-100 pb-3">
            <h2 className="text-base font-semibold text-slate-900">Protection &amp; Trace Limitations</h2>
            <span className="text-xs text-slate-500 font-mono">recovery/analysis.json</span>
          </div>
          <div className="space-y-3 text-sm">
            <div className="flex items-start gap-2.5">
              <ShieldAlert className="w-4 h-4 text-amber-600 shrink-0 mt-0.5" />
              <div>
                <div className="font-medium text-slate-900">Detected Guardrails</div>
                <p className="text-xs text-slate-600 mt-0.5">
                  Environment lock on <span className="font-mono">game.PlaceId</span> and anti-tamper check firing on{' '}
                  <span className="font-mono">debug.getupvalues</span>.
                </p>
              </div>
            </div>
            <div className="flex items-start gap-2.5">
              <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0 mt-0.5" />
              <div>
                <div className="font-medium text-slate-900">Recovered in Sandbox Trace</div>
                <p className="text-xs text-slate-600 mt-0.5">
                  {(callbackCoverage.callbacks_com_corpo_util ?? []).join(', ') || 'JumpShoot, Hitbox controls'} — full UI tree (166 elements) and 655 verified string literals.
                </p>
              </div>
            </div>
            <div className="flex items-start gap-2.5">
              <AlertTriangle className="w-4 h-4 text-red-600 shrink-0 mt-0.5" />
              <div>
                <div className="font-medium text-slate-900">Non-Recoverable Without Runtime</div>
                <p className="text-xs text-slate-600 mt-0.5">
                  {callbackCoverage.limitacao_medida || 'Trace budget caps at 2500 emits per callback; live EntityMap and remote bodies require the Roblox engine.'}
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Forensic Reports Viewer */}
      <section className="rounded-lg border border-slate-200 bg-white overflow-hidden">
        <div className="border-b border-slate-200 px-6 py-4 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
          <div className="flex items-center gap-2">
            <FileText className="w-4 h-4 text-slate-500" />
            <h2 className="text-base font-semibold text-slate-900">Repository Forensic Reports</h2>
          </div>
          <div className="flex flex-wrap items-center gap-1 p-1 bg-slate-100 rounded-lg">
            {reports.map((r) => (
              <button
                key={r.id}
                onClick={() => setSelectedReportId(r.id)}
                className={`px-3 py-1.5 text-xs font-medium rounded-md transition-colors whitespace-nowrap shrink-0 cursor-pointer ${
                  selectedReportId === r.id
                    ? 'bg-white text-slate-900 shadow-xs'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                {r.id === 'readme'
                  ? 'README'
                  : r.id === 'recovery'
                  ? 'AV0X Recovery'
                  : r.id === 'trident_v4'
                  ? 'Trident V4'
                  : r.id === 'comparison'
                  ? 'Reference Diff'
                  : 'Protections'}
              </button>
            ))}
          </div>
        </div>

        <div className="p-6">
          {reportMeta && (
            <div className="mb-4 pb-3 border-b border-slate-100">
              <h3 className="text-sm font-semibold text-slate-900">{reportMeta.title}</h3>
              <p className="text-xs text-slate-500 mt-0.5">{reportMeta.subtitle}</p>
            </div>
          )}
          {loadingReport ? (
            <div className="h-64 bg-slate-50 rounded-md animate-pulse" />
          ) : (
            <pre className="text-xs font-mono text-slate-700 bg-slate-50 border border-slate-200 rounded-md p-4 overflow-x-auto max-h-[480px] overflow-y-auto whitespace-pre-wrap leading-relaxed">
              {reportContent}
            </pre>
          )}
        </div>
      </section>
    </div>
  );
}
