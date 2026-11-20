export type WorkspaceTab = 'overview' | 'deob-lab' | 'strings' | 'schema';

export interface OverviewPayload {
  overview: {
    analysis: {
      alvo?: {
        loader?: string;
        payload_efetivo?: string;
        bytes?: number;
        sha256?: string;
      };
      protecao?: {
        primaria?: string;
        camadas?: string[];
        bytecode_luau?: boolean;
      };
      recuperacao?: {
        constantes_totais?: number;
        constantes_legiveis?: number;
        menu_elementos?: number;
        linhas_reconstruidas?: number;
      };
    };
    wadLiftReport: {
      bytes?: number;
      protecao?: string[];
      tabela_strings?: {
        entradas?: number;
        bytes_decodificados?: number;
        entropia?: number;
        razao_imprimivel?: number;
      };
      estrutura?: {
        funcoes_anonimas?: number;
        largura_instrucao_candidata?: number;
        periodicidade?: number;
      };
      dobra_de_constantes?: {
        expressoes_dobradas?: number;
        bytes_antes?: number;
        bytes_depois?: number;
        reducao?: number;
      };
    };
    callbackCoverage: {
      menu_elementos?: number;
      callbacks_alcancados?: number;
      callbacks_com_corpo_util?: string[];
      recuperado_por_completo?: string[];
      nao_recuperado?: string[];
      limitacao_medida?: string;
    };
    stats: {
      rayfieldLines: number;
      rayfieldControls: number;
      avoxMenuElements: number;
      avoxStringsCount: number;
      recoveryStringsCount: number;
      v4StringsCount: number;
    };
  };
  reports: Array<{
    id: string;
    title: string;
    subtitle: string;
  }>;
  samplePayloads: {
    lolSample: string;
    weAreDevsSample: string;
    foldedLuaSnippet: string;
  };
}

export interface CorpusEntry {
  id: number;
  value: string;
  category: 'URL' | 'Service / Path' | 'UI / Flag' | 'Network / Hook' | 'Constant';
}

export interface StringsResponse {
  corpus: 'avox' | 'recovery' | 'trident_v4';
  total: number;
  page: number;
  limit: number;
  totalPages: number;
  categoryCounts: Record<string, number>;
  items: CorpusEntry[];
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

export interface WadLiftResult {
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

export interface LolDecodeResult {
  rawChars: number;
  decodedBytes: number;
  hexPreview: string;
  uniqueStrings: string[];
  networkMatches: string[];
}

export interface WeAreDevsDecodeResult {
  sourceBytes: number;
  tableLiterals: number;
  alphabetSize: number;
  uniqueStrings: string[];
  printableStrings: string[];
}
