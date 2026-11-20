import { useEffect, useMemo, useState } from 'react';
import { Save, Trash2, Download, Search, Copy, Check } from 'lucide-react';
import type { AvoxMenuItem, SavedConfigPreset, UiControlSchema, UiTabSchema } from '../types';

interface SchemaStudioViewProps {
  onRequestExportModal: (jsonString: string) => void;
}

export function SchemaStudioView({ onRequestExportModal }: SchemaStudioViewProps) {
  const [tabs, setTabs] = useState<UiTabSchema[]>([]);
  const [avoxMenu, setAvoxMenu] = useState<AvoxMenuItem[]>([]);
  const [presets, setPresets] = useState<SavedConfigPreset[]>([]);
  const [activeTabId, setActiveTabId] = useState<string>('combat');
  const [viewMode, setViewMode] = useState<'rayfield' | 'avox-tree'>('rayfield');
  const [search, setSearch] = useState('');
  const [selectedPresetName, setSelectedPresetName] = useState('default');
  const [newPresetName, setNewPresetName] = useState('');
  const [values, setValues] = useState<Record<string, unknown>>({});
  const [loading, setLoading] = useState(true);
  const [statusMessage, setStatusMessage] = useState<string | null>(null);
  const [copiedFlag, setCopiedFlag] = useState<string | null>(null);

  useEffect(() => {
    Promise.all([
      fetch('/api/ui-schema').then((r) => r.json()),
      fetch('/api/configs').then((r) => r.json()),
    ])
      .then(([schemaRes, cfgRes]) => {
        setTabs(schemaRes.tabs || []);
        setAvoxMenu(schemaRes.avoxMenu || []);
        const presetList: SavedConfigPreset[] = cfgRes.presets || [];
        setPresets(presetList);
        const def = presetList.find((p) => p.name === 'default') || presetList[0];
        if (def) {
          setSelectedPresetName(def.name);
          setValues({ ...def.values });
        }
      })
      .finally(() => setLoading(false));
  }, []);

  const currentTab = useMemo(
    () => tabs.find((t) => t.id === activeTabId) || tabs[0],
    [tabs, activeTabId]
  );

  const updateValue = (flag: string, nextVal: unknown) => {
    setValues((prev) => ({ ...prev, [flag]: nextVal }));
  };

  const handleLoadPreset = (name: string) => {
    const found = presets.find((p) => p.name === name);
    if (!found) return;
    setSelectedPresetName(found.name);
    setValues({ ...found.values });
    setStatusMessage(`Loaded preset "${found.name}".`);
  };

  const handleSavePreset = async () => {
    const targetName = newPresetName.trim() || selectedPresetName;
    if (!targetName) return;
    const resp = await fetch('/api/configs', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name: targetName,
        description: 'Saved from Trident Schema Studio',
        values,
      }),
    });
    const json = await resp.json();
    if (resp.ok && json.preset) {
      setPresets((prev) => {
        const filtered = prev.filter((p) => p.name !== json.preset.name);
        return [...filtered, json.preset];
      });
      setSelectedPresetName(json.preset.name);
      setNewPresetName('');
      setStatusMessage(`Saved preset "${json.preset.name}" to in-memory SaveManager.`);
    }
  };

  const handleDeletePreset = async (name: string) => {
    const resp = await fetch(`/api/configs/${encodeURIComponent(name)}`, { method: 'DELETE' });
    if (resp.ok) {
      setPresets((prev) => prev.filter((p) => p.name !== name));
      if (selectedPresetName === name) {
        handleLoadPreset('default');
      }
      setStatusMessage(`Deleted preset "${name}".`);
    }
  };

  const serializedJson = useMemo(() => {
    return JSON.stringify(
      {
        schema: 'LinoriaSaveManager/trident_rayfield',
        preset: selectedPresetName,
        exportedAt: new Date().toISOString(),
        objects: values,
      },
      null,
      2
    );
  }, [selectedPresetName, values]);

  const filteredAvox = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return avoxMenu;
    return avoxMenu.filter(
      (item) =>
        item.name.toLowerCase().includes(q) ||
        item.type.toLowerCase().includes(q) ||
        item.breadcrumb.toLowerCase().includes(q)
    );
  }, [avoxMenu, search]);

  const renderControl = (ctrl: UiControlSchema) => {
    const val = values[ctrl.flag] ?? ctrl.defaultValue;

    return (
      <div key={ctrl.id} className="py-3 border-b border-slate-100 last:border-b-0 space-y-2">
        <div className="flex items-start justify-between gap-4">
          <div className="min-w-0">
            <div className="flex items-center gap-2">
              <span className="text-sm font-medium text-slate-900">{ctrl.name}</span>
              <span className="text-xs text-slate-400 font-mono">
                {ctrl.type} · L{ctrl.line}
              </span>
            </div>
            {ctrl.description && <p className="text-xs text-slate-500 mt-0.5">{ctrl.description}</p>}
            <div className="mt-1 flex items-center gap-2 text-xs text-slate-400 font-mono">
              <span>flag: {ctrl.flag}</span>
              <button
                onClick={() => {
                  navigator.clipboard?.writeText(ctrl.flag);
                  setCopiedFlag(ctrl.flag);
                  setTimeout(() => setCopiedFlag(null), 1000);
                }}
                className="text-slate-400 hover:text-slate-700 cursor-pointer"
                title="Copy flag key"
              >
                {copiedFlag === ctrl.flag ? <Check className="w-3 h-3 text-emerald-600" /> : <Copy className="w-3 h-3" />}
              </button>
            </div>
          </div>

          <div className="shrink-0 flex items-center">
            {ctrl.type === 'Toggle' && (
              <button
                type="button"
                role="switch"
                aria-checked={Boolean(val)}
                onClick={() => updateValue(ctrl.flag, !Boolean(val))}
                className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors cursor-pointer ${
                  Boolean(val) ? 'bg-teal-700' : 'bg-slate-200'
                }`}
              >
                <span
                  className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                    Boolean(val) ? 'translate-x-6' : 'translate-x-1'
                  }`}
                />
              </button>
            )}

            {ctrl.type === 'ColorPicker' && (
              <div className="flex items-center gap-2">
                <input
                  type="color"
                  value={typeof val === 'string' && val.startsWith('#') ? val : '#0f766e'}
                  onChange={(e) => updateValue(ctrl.flag, e.target.value)}
                  className="h-7 w-9 rounded border border-slate-200 cursor-pointer bg-white"
                />
                <span className="font-mono text-xs text-slate-600">
                  {typeof val === 'string' ? val : '#0f766e'}
                </span>
              </div>
            )}

            {ctrl.type === 'Dropdown' && ctrl.options && (
              <select
                value={String(val ?? ctrl.options[0] ?? '')}
                onChange={(e) => updateValue(ctrl.flag, e.target.value)}
                className="rounded-md border border-slate-200 bg-slate-50 px-2.5 py-1.5 text-xs text-slate-900 focus:outline-none focus:ring-2 focus:ring-teal-600"
              >
                {ctrl.options.map((opt) => (
                  <option key={opt} value={opt}>
                    {opt}
                  </option>
                ))}
              </select>
            )}

            {ctrl.type === 'Keybind' && (
              <span className="font-mono text-xs px-2.5 py-1 rounded border border-slate-200 bg-slate-50 text-slate-700">
                {String(val || 'None')}
              </span>
            )}

            {ctrl.type === 'Button' && (
              <span className="text-xs text-slate-500 font-mono">Action (Roblox Runtime Only)</span>
            )}

            {(ctrl.type === 'Label' || ctrl.type === 'Console') && (
              <span className="text-xs text-slate-400 font-mono">Display Widget</span>
            )}
          </div>
        </div>

        {ctrl.type === 'Slider' && ctrl.range && (
          <div className="flex items-center gap-3 pt-1">
            <input
              type="range"
              min={ctrl.range[0]}
              max={ctrl.range[1]}
              step={ctrl.increment ?? 1}
              value={Number(val ?? ctrl.range[0])}
              onChange={(e) => updateValue(ctrl.flag, parseFloat(e.target.value))}
              className="flex-1 accent-teal-700 cursor-pointer"
            />
            <span className="font-mono text-xs font-medium text-slate-800 w-16 text-right tabular-nums">
              {String(val ?? 0)}
              {ctrl.suffix ?? ''}
            </span>
          </div>
        )}

        {ctrl.type === 'Input' && (
          <input
            type="text"
            value={String(val ?? '')}
            onChange={(e) => updateValue(ctrl.flag, e.target.value)}
            className="w-full rounded-md border border-slate-200 bg-slate-50 px-2.5 py-1.5 text-xs font-mono text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-600"
          />
        )}
      </div>
    );
  };

  if (loading) {
    return <div className="h-96 rounded-lg border border-slate-200 bg-white animate-pulse" />;
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold text-slate-900">UI &amp; SaveManager Schema Studio</h1>
          <p className="text-sm text-slate-600 mt-1">
            Live AST extraction of all controls from <span className="font-mono text-slate-800">trident_rayfield.lua</span> and the 166-element{' '}
            <span className="font-mono text-slate-800">AV0X_menu.txt</span> VM trace tree.
          </p>
        </div>

        <div className="flex items-center gap-1 p-1 bg-slate-100 rounded-lg self-start">
          <button
            onClick={() => setViewMode('rayfield')}
            className={`px-3 py-1.5 text-xs font-medium rounded-md transition-colors whitespace-nowrap shrink-0 cursor-pointer ${
              viewMode === 'rayfield' ? 'bg-white text-slate-900 shadow-xs' : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            Rayfield / Linoria Schema
          </button>
          <button
            onClick={() => setViewMode('avox-tree')}
            className={`px-3 py-1.5 text-xs font-medium rounded-md transition-colors whitespace-nowrap shrink-0 cursor-pointer ${
              viewMode === 'avox-tree' ? 'bg-white text-slate-900 shadow-xs' : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            AV0X Trace Tree ({avoxMenu.length})
          </button>
        </div>
      </div>

      {/* SaveManager Preset Toolbar */}
      <div className="rounded-lg border border-slate-200 bg-white p-4 flex flex-col lg:flex-row lg:items-center justify-between gap-4">
        <div className="flex flex-wrap items-center gap-2">
          <span className="text-xs font-medium text-slate-500">SaveManager Presets:</span>
          {presets.map((p) => (
            <div key={p.name} className="inline-flex items-center rounded-md border border-slate-200 overflow-hidden">
              <button
                onClick={() => handleLoadPreset(p.name)}
                className={`px-2.5 py-1 text-xs font-medium transition-colors cursor-pointer ${
                  selectedPresetName === p.name
                    ? 'bg-teal-700 text-white'
                    : 'bg-slate-50 text-slate-700 hover:bg-slate-100'
                }`}
              >
                {p.name}
              </button>
              {p.name !== 'default' && (
                <button
                  onClick={() => handleDeletePreset(p.name)}
                  aria-label={`Delete preset ${p.name}`}
                  className="px-1.5 py-1 bg-slate-50 text-slate-400 hover:text-red-600 border-l border-slate-200 cursor-pointer"
                >
                  <Trash2 className="w-3 h-3" />
                </button>
              )}
            </div>
          ))}
        </div>

        <div className="flex flex-wrap items-center gap-2">
          <input
            type="text"
            value={newPresetName}
            onChange={(e) => setNewPresetName(e.target.value)}
            placeholder="New preset name..."
            className="rounded-md border border-slate-200 bg-slate-50 px-2.5 py-1.5 text-xs text-slate-900 focus:outline-none focus:ring-2 focus:ring-teal-600"
          />
          <button
            onClick={handleSavePreset}
            className="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-white bg-slate-900 hover:bg-slate-800 rounded-md transition-colors cursor-pointer"
          >
            <Save className="w-3.5 h-3.5" />
            Save Preset
          </button>
          <button
            onClick={() => onRequestExportModal(serializedJson)}
            className="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-teal-800 bg-teal-50 hover:bg-teal-100 border border-teal-200 rounded-md transition-colors cursor-pointer"
          >
            <Download className="w-3.5 h-3.5" />
            View JSON
          </button>
        </div>
      </div>

      {statusMessage && (
        <div className="text-xs text-teal-800 bg-teal-50 border border-teal-200 rounded-md px-3 py-2">
          {statusMessage}
        </div>
      )}

      {viewMode === 'rayfield' ? (
        <div className="space-y-4">
          {/* Tab Bar + Search */}
          <div className="flex flex-col md:flex-row md:items-center justify-between gap-3">
            <div className="flex flex-wrap items-center gap-1 p-1 bg-slate-100 rounded-lg">
              {tabs.map((tab) => {
                const count = tab.sections.reduce((s, sec) => s + sec.controls.length, 0);
                return (
                  <button
                    key={tab.id}
                    onClick={() => setActiveTabId(tab.id)}
                    className={`px-3 py-1.5 text-xs font-medium rounded-md transition-colors whitespace-nowrap shrink-0 cursor-pointer ${
                      activeTabId === tab.id ? 'bg-white text-slate-900 shadow-xs' : 'text-slate-600 hover:text-slate-900'
                    }`}
                  >
                    {tab.name} ({count})
                  </button>
                );
              })}
            </div>

            <div className="relative w-full md:w-64">
              <Search className="w-3.5 h-3.5 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
              <input
                type="text"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Search controls or flags..."
                className="w-full pl-8 pr-3 py-1.5 text-xs rounded-md border border-slate-200 bg-white text-slate-900 focus:outline-none focus:ring-2 focus:ring-teal-600"
              />
            </div>
          </div>

          {/* 2-Column Groupbox Grid (reproducing Linoria layout) */}
          {currentTab && (
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 items-start">
              {(['left', 'right'] as const).map((col) => {
                const sections = currentTab.sections
                  .filter((sec) => sec.column === col)
                  .map((sec) => ({
                    ...sec,
                    controls: search.trim()
                      ? sec.controls.filter(
                          (c) =>
                            c.name.toLowerCase().includes(search.toLowerCase()) ||
                            c.flag.toLowerCase().includes(search.toLowerCase())
                        )
                      : sec.controls,
                  }))
                  .filter((sec) => sec.controls.length > 0);

                return (
                  <div key={col} className="space-y-6">
                    {sections.map((sec) => (
                      <div key={sec.name} className="rounded-lg border border-slate-200 bg-white p-5">
                        <div className="border-b border-slate-200 pb-2.5 mb-2 flex items-center justify-between">
                          <h3 className="text-sm font-semibold text-slate-900">{sec.name}</h3>
                          <span className="text-xs text-slate-400 font-mono tabular-nums">
                            {sec.controls.length} controls
                          </span>
                        </div>
                        <div>{sec.controls.map(renderControl)}</div>
                      </div>
                    ))}
                  </div>
                );
              })}
            </div>
          )}
        </div>
      ) : (
        <div className="rounded-lg border border-slate-200 bg-white overflow-hidden">
          <div className="p-4 border-b border-slate-200 flex items-center justify-between gap-4">
            <div className="relative flex-1 max-w-md">
              <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
              <input
                type="text"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Search AV0X menu nodes..."
                className="w-full pl-9 pr-3 py-1.5 text-xs rounded-md border border-slate-200 bg-slate-50 text-slate-900 focus:outline-none focus:ring-2 focus:ring-teal-600"
              />
            </div>
            <span className="text-xs text-slate-500 tabular-nums">{filteredAvox.length} elements</span>
          </div>
          <div className="overflow-x-auto max-h-[560px] overflow-y-auto">
            <table className="w-full text-left border-collapse">
              <thead className="sticky top-0 bg-slate-50 border-b border-slate-200 text-xs font-medium text-slate-500">
                <tr>
                  <th className="py-2.5 px-4 w-16">#</th>
                  <th className="py-2.5 px-4 w-32">Control Type</th>
                  <th className="py-2.5 px-4">Control Name</th>
                  <th className="py-2.5 px-4">Trace Breadcrumb</th>
                  <th className="py-2.5 px-4 w-32">Default</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-xs">
                {filteredAvox.map((item) => (
                  <tr key={item.index} className="hover:bg-slate-50">
                    <td className="py-2 px-4 font-mono text-slate-400 tabular-nums">{item.index}</td>
                    <td className="py-2 px-4 font-mono text-teal-800">{item.type}</td>
                    <td className="py-2 px-4 font-medium text-slate-900">{item.name}</td>
                    <td className="py-2 px-4 text-slate-500 font-mono text-[11px]">{item.breadcrumb}</td>
                    <td className="py-2 px-4 font-mono text-slate-700">{item.defaultValue}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}
