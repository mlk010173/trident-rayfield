import { useEffect, useState } from 'react';
import { X, Copy, Check } from 'lucide-react';
import type { OverviewPayload, WorkspaceTab } from './types';
import { OverviewView } from './components/OverviewView';
import { DeobLabView } from './components/DeobLabView';
import { StringCorpusView } from './components/StringCorpusView';
import { SchemaStudioView } from './components/SchemaStudioView';

export function App() {
  const [activeTab, setActiveTab] = useState<WorkspaceTab>('overview');
  const [overviewData, setOverviewData] = useState<OverviewPayload | null>(null);
  const [loading, setLoading] = useState(true);
  const [exportJson, setExportJson] = useState<string | null>(null);
  const [copiedExport, setCopiedExport] = useState(false);

  useEffect(() => {
    fetch('/api/overview')
      .then((r) => r.json())
      .then((res: OverviewPayload) => setOverviewData(res))
      .finally(() => setLoading(false));
  }, []);

  const handleGlobalExport = async () => {
    const resp = await fetch('/api/configs');
    const json = await resp.json();
    setExportJson(JSON.stringify(json, null, 2));
  };

  const navItems: Array<{ id: WorkspaceTab; label: string }> = [
    { id: 'overview', label: 'Overview' },
    { id: 'deob-lab', label: 'Deobfuscation Lab' },
    { id: 'strings', label: 'String Corpus' },
    { id: 'schema', label: 'Schema Studio' },
  ];

  return (
    <div className="min-h-screen flex flex-col bg-slate-50 text-slate-900">
      {/* 3-Zone Top Bar Contract */}
      <header className="sticky top-0 z-30 bg-white border-b border-slate-200 px-6 py-3.5">
        <div className="max-w-7xl mx-auto flex items-center justify-between gap-8">
          {/* Zone 1: Single text element wordmark */}
          <button
            onClick={() => setActiveTab('overview')}
            className="text-base font-bold tracking-tight text-slate-900 whitespace-nowrap shrink-0 cursor-pointer"
          >
            Trident Workbench
          </button>

          {/* Zone 2: Clean single-line text navigation links */}
          <nav className="flex items-center gap-6 overflow-x-auto">
            {navItems.map((item) => (
              <button
                key={item.id}
                onClick={() => setActiveTab(item.id)}
                className={`text-sm font-medium whitespace-nowrap shrink-0 pb-0.5 border-b-2 transition-colors cursor-pointer ${
                  activeTab === item.id
                    ? 'border-teal-700 text-slate-900'
                    : 'border-transparent text-slate-600 hover:text-slate-900'
                }`}
              >
                {item.label}
              </button>
            ))}
          </nav>

          {/* Zone 3: 1 primary action */}
          <div className="shrink-0">
            <button
              onClick={handleGlobalExport}
              className="px-4 py-2 text-xs font-medium text-white bg-teal-700 hover:bg-teal-800 rounded-lg transition-colors whitespace-nowrap shrink-0 cursor-pointer"
            >
              Export Presets
            </button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1 w-full max-w-7xl mx-auto px-6 py-8">
        {activeTab === 'overview' && <OverviewView data={overviewData} loading={loading} />}
        {activeTab === 'deob-lab' && (
          <DeobLabView samplePayloads={overviewData?.samplePayloads ?? null} />
        )}
        {activeTab === 'strings' && <StringCorpusView />}
        {activeTab === 'schema' && (
          <SchemaStudioView onRequestExportModal={(json) => setExportJson(json)} />
        )}
      </main>

      {/* Quiet Footer */}
      <footer className="border-t border-slate-200 bg-white px-6 py-4">
        <div className="max-w-7xl mx-auto flex flex-col sm:flex-row sm:items-center justify-between gap-2 text-xs text-slate-500">
          <span>Trident Analysis Workbench · Static Luau Deobfuscation &amp; Schema Explorer</span>
          <span>Migrated from mlk010173/trident-rayfield</span>
        </div>
      </footer>

      {/* JSON Export Modal */}
      {exportJson !== null && (
        <div className="fixed inset-0 z-50 bg-slate-900/50 flex items-center justify-center p-4">
          <div className="bg-white border border-slate-200 rounded-lg max-w-2xl w-full overflow-hidden shadow-xl">
            <div className="px-5 py-3.5 border-b border-slate-200 flex items-center justify-between">
              <h3 className="text-sm font-semibold text-slate-900">Serialized SaveManager JSON</h3>
              <button
                onClick={() => setExportJson(null)}
                aria-label="Close modal"
                className="text-slate-400 hover:text-slate-700 p-1 cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>
            <div className="p-5 space-y-3">
              <pre className="rounded-md border border-slate-200 bg-slate-50 p-3 font-mono text-xs text-slate-800 max-h-96 overflow-y-auto">
                {exportJson}
              </pre>
              <div className="flex justify-end gap-2">
                <button
                  onClick={() => {
                    navigator.clipboard?.writeText(exportJson);
                    setCopiedExport(true);
                    setTimeout(() => setCopiedExport(false), 1500);
                  }}
                  className="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-white bg-teal-700 hover:bg-teal-800 rounded-md cursor-pointer"
                >
                  {copiedExport ? <Check className="w-3.5 h-3.5" /> : <Copy className="w-3.5 h-3.5" />}
                  {copiedExport ? 'Copied JSON' : 'Copy JSON'}
                </button>
                <button
                  onClick={() => setExportJson(null)}
                  className="px-3 py-1.5 text-xs font-medium text-slate-700 border border-slate-200 rounded-md hover:bg-slate-50 cursor-pointer"
                >
                  Close
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default App;
