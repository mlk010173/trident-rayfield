#!/usr/bin/env python3
"""Desofuscador para a familia de VM "LOL!" usada em scripts Roblox
(Trident V4 / PSU-style). Nao recompila o bytecode: decodifica o
container e extrai os constantes (strings, numeros) que revelam o
protocolo, os remotes e as features do script.

Uso:
    python3 deob_lol.py <script_obfuscado.lua> [saida_dir]

Saida:
    payload.bin      container decodificado (bytecode + constantes)
    strings.txt      constantes de texto legiveis
    remotes.txt      linhas que parecem remote/URL/argumento de rede
"""
import re, sys, os, collections

def extract_payload(src):
    # o decodificador sempre recebe o payload como string literal:
    #   v15("LOL!<hex>", ...)
    m = re.search(r'"((?:[^"\\]|\\.)*)"', src)
    candidatos = [(len(x), x) for x in re.findall(r'"((?:[^"\\]|\\.)*)"', src)]
    if not candidatos:
        raise SystemExit("nenhum literal de string encontrado")
    candidatos.sort(reverse=True)
    return candidatos[0][1]

def decode_lol(raw):
    """'LOL!' + pares hex, com marcador <n>O = repetir o PROXIMO byte n vezes."""
    body = raw[4:] if raw.startswith("LOL!") else raw
    out = bytearray()
    pend = None
    i = 0
    while i + 1 < len(body):
        ch = body[i:i + 2]
        if len(ch) < 2:
            break
        if ch[1] == "O":
            try:
                pend = int(ch[0])
            except ValueError:
                pass
        else:
            try:
                b = int(ch, 16)
            except ValueError:
                i += 2
                continue
            out.extend([b] * (pend if pend else 1))
            pend = None
        i += 2
    return bytes(out)

def readable(data, minlen=4):
    vistos, saida = set(), []
    for r in re.findall(rb"[\x20-\x7e]{%d,}" % minlen, data):
        s = r.decode("ascii")
        if s not in vistos:
            vistos.add(s)
            saida.append(s)
    return saida

NET = re.compile(r"(FireServer|InvokeServer|RemoteEvent|RemoteFunction|HttpGet|http|TCP|"
                 r"Shared\.entities|EntityMap|LocalCharacter|hookfunction|getgc|"
                 r"ProximityPrompt|Hitbox|Silent|aimbot|killaura|esp|ESP)", re.I)

def main():
    if len(sys.argv) < 2:
        print(__doc__)
        raise SystemExit(1)
    src = open(sys.argv[1], encoding="utf-8", errors="replace").read()
    outdir = sys.argv[2] if len(sys.argv) > 2 else "deob_out"
    os.makedirs(outdir, exist_ok=True)

    raw = extract_payload(src)
    data = decode_lol(raw)
    open(os.path.join(outdir, "payload.bin"), "wb").write(data)
    texto = readable(data)
    open(os.path.join(outdir, "strings.txt"), "w").write("\n".join(texto))
    interessantes = [s for s in texto if NET.search(s)]
    open(os.path.join(outdir, "remotes.txt"), "w").write("\n".join(interessantes))

    print("payload: %d chars -> %d bytes" % (len(raw), len(data)))
    print("strings unicas: %d | relevantes (rede/protocolo): %d" % (len(texto), len(interessantes)))
    print("arquivos em", outdir)
    for s in interessantes[:25]:
        print("  ", s[:90])

if __name__ == "__main__":
    main()
