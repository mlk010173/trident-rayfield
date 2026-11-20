import { useEffect, useState } from 'react';
import { Search, Copy, Check, ChevronLeft, ChevronRight } from 'lucide-react';
import type { StringsResponse } from '../types';

const CORPORA: Array<{ id: 'recovery' | 'avox' | 'trident_v4'; label: string }> = [
  { id: 'recovery', label: 'AV0X Verified (655)' },
  { id: 'avox', label: 'AV0X Full Table (4,416)' },
  { id: 'trident_v4', label: 'Trident V4 Constants (235)' },
];

const CATEGORIES = ['All', 'URL', 'Service / Path', 'Network / Hook', 'UI / Flag', 'Constant'];

export function StringCorpusView() {
  const [corpus, setCorpus] = useState<'recovery' | 'avox' | 'trident_v4'>('recovery');
  const [category, setCategory] = useState<string>('All');
  const [query, setQuery] = useState<string>('');
  const [debouncedQuery, setDebouncedQuery] = useState<string>('');
  const [page, setPage] = useState<number>(1);
  const [data, setData] = useState<StringsResponse | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [copiedId, setCopiedId] = useState<number | null>(null);

  useEffect(() => {
    const t = setTimeout(() => {
      setDebouncedQuery(query);
      setPage(1);
    }, 180);
    return () => clearTimeout(t);
  }, [query]);

  useEffect(() => {
    let active = true;
    setLoading(true);
    const params = new URLSearchParams({
      corpus,
      category,
      q: debouncedQuery,
      page: String(page),
      limit: '50',
    });
    fetch(`/api/strings?${params.toString()}`)
      .then((r) => r.json())
      .then((res: StringsResponse) => {
        if (active) setData(res);
      })
      .finally(() => {
        if (active) setLoading(false);
      });
    return () => {
      active = false;
    };
  }, [corpus, category, debouncedQuery, page]);

  const copyLine = (id: number, val: string) => {
    navigator.clipboard?.writeText(val);
    setCopiedId(id);
    setTimeout(() => setCopiedId(null), 1200);
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold text-slate-900">Extracted String Corpora</h1>
          <p className="text-sm text-slate-600 mt-1">
            Inspect decoded VM string tables from <span className="font-mono text-slate-800">recovery/strings.txt</span>,{' '}
            <span className="font-mono text-slate-800">deob/avox_strings.txt</span>, and{' '}
            <span className="font-mono text-slate-800">deob/trident_v4_strings.txt</span>.
          </p>
        </div>

        <div className="flex items-center gap-1 p-1 bg-slate-100 rounded-lg self-start">
          {CORPORA.map((c) => (
            <button
              key={c.id}
              onClick={() => {
                setCorpus(c.id);
                setPage(1);
              }}
              className={`px-3 py-1.5 text-xs font-medium rounded-md transition-colors whitespace-nowrap shrink-0 cursor-pointer ${
                corpus === c.id ? 'bg-white text-slate-900 shadow-xs' : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              {c.label}
            </button>
          ))}
        </div>
      </div>

      {/* Filter Toolbar */}
      <div className="rounded-lg border border-slate-200 bg-white p-4 space-y-3">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-3">
          <div className="relative flex-1 max-w-md">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Filter decoded strings (e.g. HttpGet, Hitbox, Shared.entities)..."
              className="w-full pl-9 pr-3 py-2 text-sm rounded-md border border-slate-200 bg-slate-50 text-slate-900 focus:outline-none focus:ring-2 focus:ring-teal-600 focus:bg-white"
            />
          </div>

          <div className="flex flex-wrap items-center gap-1 p-1 bg-slate-100 rounded-lg">
            {CATEGORIES.map((cat) => {
              const count = data?.categoryCounts?.[cat];
              return (
                <button
                  key={cat}
                  onClick={() => {
                    setCategory(cat);
                    setPage(1);
                  }}
                  className={`px-2.5 py-1 text-xs font-medium rounded-md transition-colors whitespace-nowrap shrink-0 cursor-pointer ${
                    category === cat ? 'bg-white text-slate-900 shadow-xs' : 'text-slate-600 hover:text-slate-900'
                  }`}
                >
                  {cat}
                  {typeof count === 'number' ? ` (${count})` : ''}
                </button>
              );
            })}
          </div>
        </div>
      </div>

      {/* Data Table */}
      <div className="rounded-lg border border-slate-200 bg-white overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b border-slate-200 bg-slate-50 text-xs font-medium text-slate-500">
                <th className="py-2.5 px-4 w-20">#</th>
                <th className="py-2.5 px-4 w-40">Classification</th>
                <th className="py-2.5 px-4">Extracted String Value</th>
                <th className="py-2.5 px-4 w-20 text-right">Copy</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-xs">
              {loading ? (
                Array.from({ length: 8 }).map((_, i) => (
                  <tr key={i} className="h-10">
                    <td colSpan={4} className="px-4">
                      <div className="h-4 bg-slate-100 rounded animate-pulse" />
                    </td>
                  </tr>
                ))
              ) : !data || data.items.length === 0 ? (
                <tr>
                  <td colSpan={4} className="py-10 text-center text-sm text-slate-500">
                    No matching string literals found for this filter.
                  </td>
                </tr>
              ) : (
                data.items.map((item) => (
                  <tr key={item.id} className="hover:bg-slate-50/80 transition-colors">
                    <td className="py-2.5 px-4 font-mono text-slate-400 tabular-nums">{item.id}</td>
                    <td className="py-2.5 px-4 font-medium text-slate-700 whitespace-nowrap">{item.category}</td>
                    <td className="py-2.5 px-4 font-mono text-slate-900 break-all">{item.value}</td>
                    <td className="py-2.5 px-4 text-right">
                      <button
                        onClick={() => copyLine(item.id, item.value)}
                        aria-label={`Copy ${item.value}`}
                        className="inline-flex items-center justify-center p-1.5 text-slate-400 hover:text-slate-900 rounded cursor-pointer"
                      >
                        {copiedId === item.id ? (
                          <Check className="w-3.5 h-3.5 text-emerald-600" />
                        ) : (
                          <Copy className="w-3.5 h-3.5" />
                        )}
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        {data && (
          <div className="border-t border-slate-200 px-4 py-3 flex items-center justify-between text-xs text-slate-600">
            <span className="tabular-nums">
              Showing {data.items.length} of {data.total.toLocaleString()} matches · Page {data.page} of {data.totalPages}
            </span>
            <div className="flex items-center gap-2">
              <button
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                disabled={data.page <= 1}
                className="inline-flex items-center gap-1 px-2.5 py-1 border border-slate-200 rounded-md hover:bg-slate-50 disabled:opacity-40 cursor-pointer"
              >
                <ChevronLeft className="w-3.5 h-3.5" />
                Prev
              </button>
              <button
                onClick={() => setPage((p) => Math.min(data.totalPages, p + 1))}
                disabled={data.page >= data.totalPages}
                className="inline-flex items-center gap-1 px-2.5 py-1 border border-slate-200 rounded-md hover:bg-slate-50 disabled:opacity-40 cursor-pointer"
              >
                Next
                <ChevronRight className="w-3.5 h-3.5" />
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
