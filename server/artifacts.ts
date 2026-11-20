import fs from 'node:fs';
import path from 'node:path';

export interface CorpusEntry {
  id: number;
  value: string;
  category: 'URL' | 'Service / Path' | 'UI / Flag' | 'Network / Hook' | 'Constant';
}

export interface UiControlSchema {
  id: string;
  type: 'Toggle' | 'Slider' | 'Dropdown' | 'Keybind' | 'ColorPicker' | 'Input' | 'Button' | 'Label' | 'Console';
  name: string;
  flag: string;
  description?: string;
  defaultValue: unknown;
  range?: [number, number];
  increment?: number;
  suffix?: string;
  options?: string[];
  line: number;
}

export interface UiSectionSchema {
  name: string;
  column: 'left' | 'right';
  controls: UiControlSchema[];
}

export interface UiTabSchema {
  id: string;
  name: string;
  sections: UiSectionSchema[];
}

export interface AvoxMenuItem {
  index: number;
  breadcrumb: string;
  type: string;
  name: string;
  defaultValue: string;
}

export interface SavedConfigPreset {
  name: string;
  description: string;
  updatedAt: string;
  values: Record<string, unknown>;
}

const ROOT = process.cwd();

function readTextSafe(relPath: string): string {
  try {
    return fs.readFileSync(path.join(ROOT, relPath), 'utf8');
  } catch {
    return '';
  }
}

function readJsonSafe<T>(relPath: string, fallback: T): T {
  try {
    return JSON.parse(fs.readFileSync(path.join(ROOT, relPath), 'utf8')) as T;
  } catch {
    return fallback;
  }
}

function classifyString(s: string): CorpusEntry['category'] {
  if (/^https?:\/\//i.test(s) || /github|scriptblox|rawscripts|wearedevs|discord\.gg/i.test(s)) {
    return 'URL';
  }
  if (/(FireServer|InvokeServer|hookfunction|getgc|debug\.get|TCP|EntityMap|CreateProjectile|Tamper)/i.test(s)) {
    return 'Network / Hook';
  }
  if (/(Players|Workspace|ReplicatedStorage|RunService|UserInputService|Lighting|LocalCharacter|Shared\.entities|Drawing\.new|Color3)/i.test(s)) {
    return 'Service / Path';
  }
  if (/^[A-Z][a-zA-Z0-9]*_[A-Za-z0-9_]+$/.test(s) || /(Enable|Hitbox|Esp|ESP|Chams|Fov|Config|Theme|Key|Slider|Toggle)/.test(s)) {
    return 'UI / Flag';
  }
  return 'Constant';
}

function parseCorpus(raw: string, skipCommentLines = false): CorpusEntry[] {
  const lines = raw.split(/\r?\n/);
  const entries: CorpusEntry[] = [];
  let idx = 1;
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed) continue;
    if (skipCommentLines && trimmed.startsWith('#')) continue;
    entries.push({
      id: idx++,
      value: trimmed,
      category: classifyString(trimmed),
    });
  }
  return entries;
}

function parseColor3(expr: string): string {
  const m = /Color3\.fromRGB\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)/.exec(expr);
  if (!m) return '#0f766e';
  const hex = [m[1], m[2], m[3]]
    .map((n) => Math.max(0, Math.min(255, parseInt(n, 10))).toString(16).padStart(2, '0'))
    .join('');
  return `#${hex}`;
}

function parseStringArray(expr: string): string[] {
  const out: string[] = [];
  const reg = /"([^"]*)"/g;
  let m: RegExpExecArray | null;
  while ((m = reg.exec(expr)) !== null) {
    out.push(m[1]);
  }
  return out;
}

export function parseRayfieldUiSchema(luaSource: string): UiTabSchema[] {
  const lines = luaSource.split(/\r?\n/);
  const tabVarMap: Record<string, { id: string; name: string }> = {
    TCombat: { id: 'combat', name: 'Combat' },
    TVisual: { id: 'esp', name: 'ESP' },
    TWorld: { id: 'visuals', name: 'Visuals' },
    TMove: { id: 'movement', name: 'Movement' },
    TObj: { id: 'objetos', name: 'Objetos' },
    TConfig: { id: 'ui-settings', name: 'UI Settings' },
  };

  const tabs = new Map<string, UiTabSchema>();
  for (const t of Object.values(tabVarMap)) {
    tabs.set(t.id, { id: t.id, name: t.name, sections: [] });
  }

  let currentSection: UiSectionSchema | null = null;
  const sectionCounters = new Map<string, number>();

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const secMatch = /^(T\w+):CreateSection\(\{\s*name\s*=\s*"([^"]+)"\s*\}\)/.exec(line.trim());
    if (secMatch) {
      const tabInfo = tabVarMap[secMatch[1]];
      if (tabInfo) {
        const count = sectionCounters.get(tabInfo.id) ?? 0;
        sectionCounters.set(tabInfo.id, count + 1);
        const section: UiSectionSchema = {
          name: secMatch[2],
          column: count % 2 === 0 ? 'left' : 'right',
          controls: [],
        };
        tabs.get(tabInfo.id)?.sections.push(section);
        currentSection = section;
      }
      continue;
    }

    const ctrlMatch = /(?:local\s+\w+\s*=\s*)?(T\w+):Create(Toggle|Slider|Dropdown|Keybind|ColorPicker|Input|Button|Label|Console)\(\{/.exec(
      line.trim()
    );
    if (ctrlMatch) {
      const tabInfo = tabVarMap[ctrlMatch[1]];
      const type = ctrlMatch[2] as UiControlSchema['type'];
      let block = line;
      let j = i;
      let depth = (line.match(/\{/g) ?? []).length - (line.match(/\}/g) ?? []).length;
      while (depth > 0 && j + 1 < lines.length && j - i < 45) {
        j++;
        block += '\n' + lines[j];
        depth += (lines[j].match(/\{/g) ?? []).length - (lines[j].match(/\}/g) ?? []).length;
      }

      const nameMatch = /\bname\s*=\s*"([^"]*)"/.exec(block);
      const textMatch = /\btext\s*=\s*"([^"]*)"/.exec(block);
      const flagMatch = /\bflag\s*=\s*"([^"]*)"/.exec(block);
      const descMatch = /\bdescription\s*=\s*"([^"]*)"/.exec(block);
      const suffixMatch = /\bsuffix\s*=\s*"([^"]*)"/.exec(block);
      const valMatch = /\bvalue\s*=\s*([^\n,]+)/.exec(block);
      const currentOptMatch = /\bcurrentOption\s*=\s*(\{[^}]*\})/.exec(block);
      const colorMatch = /\bcolor\s*=\s*(Color3\.fromRGB\([^)]+\))/.exec(block);
      const rangeMatch = /\brange\s*=\s*\{\s*([-0-9.]+)\s*,\s*([-0-9.]+)\s*\}/.exec(block);
      const incMatch = /\bincrement\s*=\s*([0-9.]+)/.exec(block);
      const optsMatch = /\boptions\s*=\s*(\{[^}]*\})/.exec(block);

      const name = nameMatch?.[1] ?? textMatch?.[1] ?? `${type} #${i + 1}`;
      const flag = flagMatch?.[1] ?? `${tabInfo?.id ?? 'ctrl'}_${i + 1}`;
      let defaultValue: unknown = null;

      if (type === 'Toggle') {
        const rawVal = valMatch?.[1]?.trim();
        defaultValue = rawVal === 'true';
      } else if (type === 'Slider') {
        defaultValue = valMatch ? parseFloat(valMatch[1]) : 0;
        if (Number.isNaN(defaultValue as number)) defaultValue = 0;
      } else if (type === 'Dropdown') {
        const opts = optsMatch ? parseStringArray(optsMatch[1]) : [];
        if (currentOptMatch) {
          const cur = parseStringArray(currentOptMatch[1]);
          defaultValue = cur[0] ?? opts[0] ?? '';
        } else if (valMatch) {
          defaultValue = valMatch[1].replace(/^"|"$/g, '').trim();
        } else {
          defaultValue = opts[0] ?? '';
        }
      } else if (type === 'Keybind') {
        const rawVal = valMatch?.[1]?.trim() ?? 'None';
        defaultValue = rawVal.replace('Enum.KeyCode.', '');
      } else if (type === 'ColorPicker') {
        defaultValue = colorMatch ? parseColor3(colorMatch[1]) : '#0f766e';
      } else if (type === 'Input') {
        defaultValue = valMatch ? valMatch[1].replace(/^"|"$/g, '').trim() : '';
      }

      const control: UiControlSchema = {
        id: `${flag}_${i + 1}`,
        type,
        name,
        flag,
        description: descMatch?.[1],
        defaultValue,
        range: rangeMatch ? [parseFloat(rangeMatch[1]), parseFloat(rangeMatch[2])] : undefined,
        increment: incMatch ? parseFloat(incMatch[1]) : undefined,
        suffix: suffixMatch?.[1],
        options: optsMatch ? parseStringArray(optsMatch[1]) : undefined,
        line: i + 1,
      };

      if (currentSection) {
        currentSection.controls.push(control);
      } else if (tabInfo) {
        const fallbackSection: UiSectionSchema = {
          name: 'General',
          column: 'left',
          controls: [control],
        };
        tabs.get(tabInfo.id)?.sections.push(fallbackSection);
        currentSection = fallbackSection;
      }
    }
  }

  return Array.from(tabs.values());
}

function parseAvoxMenu(raw: string): AvoxMenuItem[] {
  const lines = raw.split(/\r?\n/);
  const items: AvoxMenuItem[] = [];
  let idx = 1;
  for (const line of lines) {
    const m = /^\[([^\]]*)\]\s*([^|]+)\|\s*([^|]*)\|\s*flag=[^|]*\|\s*default=(.*)$/.exec(line.trim());
    if (!m) continue;
    items.push({
      index: idx++,
      breadcrumb: m[1].trim() || 'Root',
      type: m[2].trim(),
      name: m[3].trim() || '(unnamed)',
      defaultValue: m[4].trim(),
    });
  }
  return items;
}

export interface RepoArtifacts {
  overview: {
    analysis: Record<string, unknown>;
    wadLiftReport: Record<string, unknown>;
    callbackCoverage: Record<string, unknown>;
    stats: {
      rayfieldLines: number;
      rayfieldControls: number;
      avoxMenuElements: number;
      avoxStringsCount: number;
      recoveryStringsCount: number;
      v4StringsCount: number;
    };
  };
  reports: Record<string, { title: string; subtitle: string; content: string }>;
  corpora: {
    avox: CorpusEntry[];
    recovery: CorpusEntry[];
    trident_v4: CorpusEntry[];
  };
  uiSchema: UiTabSchema[];
  avoxMenu: AvoxMenuItem[];
  samplePayloads: {
    lolSample: string;
    weAreDevsSample: string;
    foldedLuaSnippet: string;
  };
}

let cachedArtifacts: RepoArtifacts | null = null;

export function getArtifacts(): RepoArtifacts {
  if (cachedArtifacts) return cachedArtifacts;

  const analysis = readJsonSafe<Record<string, unknown>>('recovery/analysis.json', {});
  const wadLiftReport = readJsonSafe<Record<string, unknown>>('deob/wad_lift_report.json', {});
  const callbackCoverage = readJsonSafe<Record<string, unknown>>('recovery/callbacks/coverage.json', {});

  const rayfieldLua = readTextSafe('trident_rayfield.lua');
  const avoxMenuRaw = readTextSafe('deob/AV0X_menu.txt');
  const avoxStringsRaw = readTextSafe('deob/avox_strings.txt');
  const recoveryStringsRaw = readTextSafe('recovery/strings.txt');
  const v4StringsRaw = readTextSafe('deob/trident_v4_strings.txt');
  const avoxFoldedRaw = readTextSafe('deob/avox_folded.lua');

  const uiSchema = parseRayfieldUiSchema(rayfieldLua);
  const avoxMenu = parseAvoxMenu(avoxMenuRaw);

  const avoxCorpus = parseCorpus(avoxStringsRaw, false);
  const recoveryCorpus = parseCorpus(recoveryStringsRaw, true);
  const v4Corpus = parseCorpus(v4StringsRaw, false);

  const totalControls = uiSchema.reduce(
    (sum, tab) => sum + tab.sections.reduce((s2, sec) => s2 + sec.controls.length, 0),
    0
  );

  // Build deterministic educational sample payloads using the real WeAreDevs and LOL! encodings
  const lolSample = `local v15 = loadstring
-- LOL! hex + RLE (<n>O repeats next byte n times) sample
local payload = "LOL!54726964656E742056343O2046617A6D610A487474704765742068747470733A2F2F7261772E67697468756275736572636F6E74656E742E636F6D"`;

  // Real WeAreDevs style snippet with local alphabet table + local W={...} + arithmetic constant folding
  const weAreDevsSample = `--[[ v1.0.0 https://wearedevs.net/obfuscator ]]
local A = {A=0,B=1,C=2,D=3,E=4,F=5,G=6,H=7,I=8,J=9,K=10,L=11,M=12,N=13,O=14,P=15,Q=16,R=17,S=18,T=19,U=20,V=21,W=22,X=23,Y=24,Z=25,a=26,b=27,c=28,d=29,e=30,f=31,g=32,h=33,i=34,j=35,k=36,l=37,m=38,n=39,o=40,p=41,q=42,r=43,s=44,t=45,u=46,v=47,w=48,x=49,y=50,z=51,["\\048"]=52,["\\049"]=53,["\\050"]=54,["\\051"]=55,["\\052"]=56,["\\053"]=57,["\\054"]=58,["\\055"]=59,["\\056"]=60,["\\057"]=61,["\\043"]=62,["\\047"]=63}
local W = {"\\086\\071\\070\\116\\099\\071\\086\\121\\073\\069\\082\\108\\100\\071\\086\\106\\100\\071\\086\\107\\073\\081\\061\\061","\\085\\109\\086\\119\\098\\071\\108\\106\\089\\088\\082\\108\\090\\070\\078\\048\\098\\051\\074\\104\\090\\050\\085\\061","\\083\\071\\108\\048\\089\\109\\057\\052\\082\\088\\104\\119\\089\\087\\053\\107\\090\\088\\073\\061"}
while z do
  local idx = 840618+-840617
  if z < 7608014-(-817528) then
    if z == -578020+0 then return W[idx] end
  end
  z = z - 1
end`;

  cachedArtifacts = {
    overview: {
      analysis,
      wadLiftReport,
      callbackCoverage,
      stats: {
        rayfieldLines: rayfieldLua.split(/\r?\n/).length,
        rayfieldControls: totalControls,
        avoxMenuElements: avoxMenu.length,
        avoxStringsCount: avoxCorpus.length,
        recoveryStringsCount: recoveryCorpus.length,
        v4StringsCount: v4Corpus.length,
      },
    },
    reports: {
      readme: {
        title: 'Repository Overview (README.md)',
        subtitle: 'Architecture, build changelog (v2.0 – v3.4), and module breakdown',
        content: readTextSafe('README.md'),
      },
      recovery: {
        title: 'AV0X Recovery Report',
        subtitle: 'Static extraction, sandbox VM trace, and callback budget analysis',
        content: readTextSafe('recovery/recovery_report.md'),
      },
      trident_v4: {
        title: 'Trident V4 Deobfuscation Report',
        subtitle: 'LOL! VM container decoding and external dependency resolution',
        content: readTextSafe('deob/REPORT.md'),
      },
      comparison: {
        title: 'Reference Architecture Comparison',
        subtitle: 'Cross-analysis of swimhub, Babyhamsta, kira, DirtyFork, and wad_lift',
        content: readTextSafe('docs/COMPARACAO_REFERENCIAS.md'),
      },
      protections: {
        title: 'Protection & Anti-Tamper Audit',
        subtitle: 'Environment locks, PlaceId checks, and VM obfuscation layers',
        content: readTextSafe('deob/RELATORIO_PROTECOES.md'),
      },
    },
    corpora: {
      avox: avoxCorpus,
      recovery: recoveryCorpus,
      trident_v4: v4Corpus,
    },
    uiSchema,
    avoxMenu,
    samplePayloads: {
      lolSample,
      weAreDevsSample,
      foldedLuaSnippet: avoxFoldedRaw.slice(0, 6000),
    },
  };

  return cachedArtifacts;
}

export function createConfigStore(schema: UiTabSchema[]) {
  const store = new Map<string, SavedConfigPreset>();

  const baseDefaults: Record<string, unknown> = {};
  for (const tab of schema) {
    for (const section of tab.sections) {
      for (const ctrl of section.controls) {
        if (ctrl.type !== 'Button' && ctrl.type !== 'Label' && ctrl.type !== 'Console') {
          baseDefaults[ctrl.flag] = ctrl.defaultValue;
        }
      }
    }
  }

  store.set('default', {
    name: 'default',
    description: 'Parsed script defaults from trident_rayfield.lua',
    updatedAt: new Date().toISOString(),
    values: { ...baseDefaults },
  });

  store.set('mobile-safe', {
    name: 'mobile-safe',
    description: 'SafeMode enabled, center-locked screen coordinates, reduced visual overhead',
    updatedAt: new Date().toISOString(),
    values: {
      ...baseDefaults,
      safe_mode: true,
      aim_center: true,
      proj_silent: false,
      aim_smooth: 8,
    },
  });

  store.set('fps-baseline', {
    name: 'fps-baseline',
    description: 'Low-detail lighting and particle settings aligned with Perf preset',
    updatedAt: new Date().toISOString(),
    values: {
      ...baseDefaults,
      safe_mode: true,
      hb_enabled: false,
    },
  });

  return store;
}
