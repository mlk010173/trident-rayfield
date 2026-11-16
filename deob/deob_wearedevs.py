#!/usr/bin/env python3
"""Desofuscador para a familia WeAreDevs VM (cabecalho
"--[[ v1.0.0 https://wearedevs.net/obfuscator ]] return(function(...)").

O que ele faz:
  1. extrai a tabela de strings do blob (a unica tabela `local W={...}` antes da VM);
  2. acha a tabela de alfabeto (64 entradas, valores 0..63) usada pelo decoder;
  3. reproduz o decode do proprio obfuscador (base64 com alfabeto trocado,
     ../../.. grupos de 4 chars -> 3 bytes, '=' fecha o ultimo grupo);
  4. grava todas as constantes de texto em strings.txt.

Nao recompila o bytecode (isso exige um lifter especifico da VM). Ele entrega
o que e recuperavel de forma confiavel: o dicionario completo de constantes
(names de API, remotes, URLs, labels), que e o que revela o comportamento.

Uso:
    python3 deob_wearedevs.py <arquivo.lua|url> [saida_dir]
"""
import re, sys, os, json, urllib.request

UA = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/131.0 Safari/537.36"}


def load(src):
    if src.startswith("http"):
        req = urllib.request.Request(src, headers=UA)
        return urllib.request.urlopen(req, timeout=60).read().decode("utf-8", "replace")
    return open(src, encoding="utf-8", errors="replace").read()


def extract_table(s, start_marker="local W={"):
    i = s.find(start_marker)
    if i < 0:
        raise SystemExit("tabela W nao encontrada (nao parece WeAreDevs)")
    j = i + len("local W=")
    depth = 0
    for k in range(j, len(s)):
        if s[k] == "{":
            depth += 1
        elif s[k] == "}":
            depth -= 1
            if depth == 0:
                return s[j:k + 1]


def parse_numbers(expr):
    expr = expr.replace(" ", "").replace("+-", "-").replace("--", "+")
    if not re.fullmatch(r"[0-9+\-*/().]+", expr):
        raise ValueError(expr)
    return int(eval(expr))


def find_alphabet(s):
    for m in re.finditer(r"local\s+\w+\s*=\s*\{", s):
        block = extract_table(s, s[m.start():m.start() + 20].split("{")[0] + "{")
        pairs = re.findall(r'(?:([A-Za-z_]\w*)|\["\\(\d+)"\])\s*=\s*([0-9+\-*/() ]+)', block)
        alpha = {}
        try:
            for name, esc, expr in pairs:
                key = name if name else chr(int(esc))
                alpha[key] = parse_numbers(expr)
        except Exception:
            continue
        if len(alpha) == 64 and set(alpha.values()) == set(range(64)):
            return alpha
    raise SystemExit("tabela de alfabeto nao encontrada")


def unescape_lua(x):
    out, i = [], 0
    while i < len(x):
        if x[i] == "\\":
            m = re.match(r"(\d{1,3})", x[i + 1:])
            if m:
                out.append(chr(int(m.group(1))))
                i += 1 + len(m.group(0))
                continue
            out.append(x[i + 1])
            i += 2
            continue
        out.append(x[i])
        i += 1
    return "".join(out)


def decode(enc, alpha):
    v, e, d, n, p = [], 0, 0, len(enc), 1
    while p <= n:
        c = enc[p - 1]
        w = alpha.get(c)
        if w is not None:
            e += w * (64 ** (3 - d))
            d += 1
            if d == 4:
                d = 0
                v.append(chr(int(e // 65536)))
                v.append(chr(int((e % 65536) // 256)))
                v.append(chr(int(e % 256)))
                e = 0
        elif c == "=":
            v.append(chr(int(e // 65536)))
            if p >= n or enc[p] != "=":
                v.append(chr(int((e % 65536) // 256)))
            break
        p += 1
    return "".join(v)


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        raise SystemExit(1)
    src = sys.argv[1]
    outdir = sys.argv[2] if len(sys.argv) > 2 else "deob_out"
    os.makedirs(outdir, exist_ok=True)

    code = load(src)
    wtbl = extract_table(code)
    alpha = find_alphabet(code)
    lits = re.findall(r'"((?:[^"\\]|\\.)*)"', wtbl)
    decoded, seen, uniq = [], set(), []
    for lit in lits:
        try:
            txt = decode(unescape_lua(lit), alpha)
        except Exception:
            continue
        if txt and txt not in seen:
            seen.add(txt)
            uniq.append(txt)

    open(os.path.join(outdir, "strings.txt"), "w", encoding="utf-8", errors="replace").write("\n".join(uniq))
    printable = [x for x in uniq if re.fullmatch(r"[\x20-\x7e]{3,}", x)]
    open(os.path.join(outdir, "strings_readable.txt"), "w", encoding="utf-8").write("\n".join(printable))

    print("fonte: %d bytes | literais: %d | unicas: %d | legiveis: %d"
          % (len(code), len(lits), len(uniq), len(printable)))
    print("saida em", outdir)


if __name__ == "__main__":
    main()
