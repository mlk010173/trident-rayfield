#!/usr/bin/env python3
"""wad_lift.py - pipeline unico para os alvos Lua do Trident.

Etapas:
  1. deteccao de protecao (WeAreDevs, LOL-VM, MoonSec, Luraph, bytecode);
  2. decodificacao da tabela de strings (escapes decimais -> bytes);
  3. analise estrutural do blob decodificado (entropia, histograma, largura
     de instrucao candidata por periodicidade);
  4. relatorio JSON.

Nao executa o script alvo. A saida e o mapa do que da para recuperar
estaticamente; o lifting de opcode continua exigindo a tabela de dispatch.
"""
import json, math, re, sys, collections

def load(path):
    return open(path, encoding="latin1").read()

def extract_table(s, marker="local W={"):
    i = s.find(marker)
    if i < 0: return None
    j = i + len("local W=")
    depth = 0
    for k in range(j, len(s)):
        if s[k] == "{": depth += 1
        elif s[k] == "}":
            depth -= 1
            if depth == 0: return s[j:k+1]
    return None

def lua_unescape(text):
    out = bytearray()
    i = 0
    while i < len(text):
        c = text[i]
        if c == "\\" and i + 1 < len(text):
            m = re.match(r"\\(\d{1,3})", text[i:])
            if m:
                out.append(int(m.group(1)) & 0xFF); i += 1 + len(m.group(1)); continue
            nxt = text[i+1]
            mapping = {"n": 10, "t": 9, "r": 13, "\\": 92, '"': 34, "'": 39, "a": 7, "b": 8, "f": 12, "v": 11}
            if nxt in mapping: out.append(mapping[nxt]); i += 2; continue
            out.append(ord(nxt) & 0xFF); i += 2; continue
        out.append(ord(c) & 0xFF); i += 1
    return bytes(out)

def strings_of(table):
    return [lua_unescape(m) for m in re.findall(r'"((?:[^"\\]|\\.)*)"', table)]

def entropy(data):
    if not data: return 0.0
    c = collections.Counter(data)
    n = len(data)
    return -sum((v/n) * math.log2(v/n) for v in c.values())

def detect(text):
    sig = []
    if "wearedevs.net/obfuscator" in text: sig.append("WeAreDevs v1.0.0")
    if "LOL!" in text: sig.append("LOL-VM")
    if re.search(r"MoonSec", text, re.I): sig.append("MoonSec")
    if re.search(r"Luraph", text, re.I): sig.append("Luraph")
    if text.startswith("\x1bLua") or text.startswith("RBM"): sig.append("bytecode")
    return sig or ["desconhecida"]

def instruction_width(blob):
    """procura periodicidade: repeticoes de byte em intervalos fixos"""
    best, bestw = 0.0, None
    sample = blob[:20000]
    for w in (3, 4, 5, 8):
        hits = sum(1 for i in range(len(sample) - w) if sample[i] == sample[i+w])
        score = hits / max(1, len(sample) - w)
        if score > best: best, bestw = score, w
    return bestw, round(best, 3)

def main(path):
    text = load(path)
    table = extract_table(text)
    strings = strings_of(table) if table else []
    blob = b"".join(strings)
    width, score = instruction_width(blob)
    printable = sum(1 for b in blob if 32 <= b < 127) / max(1, len(blob))
    report = {
        "arquivo": path,
        "bytes": len(text),
        "protecao": detect(text),
        "tabela_strings": {
            "entradas": len(strings),
            "bytes_decodificados": len(blob),
            "entropia": round(entropy(blob), 3),
            "razao_imprimivel": round(printable, 3),
        },
        "estrutura": {
            "funcoes_anonimas": text.count("function("),
            "largura_instrucao_candidata": width,
            "periodicidade": score,
        },
        "amostra": [s.decode("latin1") for s in strings[:10] if s],
    }
    return report

if __name__ == "__main__":
    print(json.dumps(main(sys.argv[1]), ensure_ascii=False, indent=2))
