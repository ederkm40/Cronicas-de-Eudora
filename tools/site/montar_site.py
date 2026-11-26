#!/usr/bin/env python3
"""Monta o site publicado no branch gh-pages, trocando só a parte que mudou.

Estrutura publicada:
  /                         jogo oficial (main)
  /wiki/                    Wiki oficial
  /previews/                lista das prévias abertas
  /previews/pr-<N>/         jogo do Pull Request N
  /previews/pr-<N>/wiki/    Wiki do Pull Request N
  /publicacao.json          o que está publicado em cada lugar (commit, branch, data)

Uso:
  montar_site.py oficial  --site DIR --parte DIR --commit SHA
  montar_site.py previa   --site DIR --parte DIR --pr N --commit SHA --branch NOME [--titulo T]
  montar_site.py remover  --site DIR --pr N
  montar_site.py limpar   --site DIR --abertos "3 5 8"
  montar_site.py oficial-atual --site DIR      (imprime o commit do jogo oficial publicado)

"--parte" é a pasta com o jogo exportado (index.html, .js, .pck, .wasm) e a Wiki em wiki/.
Nunca apaga nada fora da área que está sendo trocada, nem a pasta .git.
Só usa a biblioteca padrão do Python.
"""

from __future__ import annotations

import argparse
import html
import json
import re
import shutil
import sys
from datetime import datetime, timezone
from pathlib import Path

ARQUIVOS_JOGO = ("index.html", "index.js", "index.pck", "index.wasm")
PROTEGIDOS_NA_RAIZ = {".git", "previews", ".nojekyll", "publicacao.json"}
NOME_PREVIA = re.compile(r"^pr-(\d+)$")


class ErroMontagem(Exception):
    pass


def validar_parte(parte: Path) -> None:
    faltando = [nome for nome in ARQUIVOS_JOGO if not (parte / nome).is_file() or (parte / nome).stat().st_size == 0]
    if faltando:
        raise ErroMontagem(f"exportação incompleta em {parte}: faltando {', '.join(faltando)}")
    if not (parte / "wiki" / "index.html").is_file():
        raise ErroMontagem(f"Wiki ausente em {parte}/wiki")


def ler_publicacao(site: Path) -> dict:
    arquivo = site / "publicacao.json"
    if arquivo.is_file():
        return json.loads(arquivo.read_text(encoding="utf-8"))
    return {"oficial": None, "previas": {}}


def salvar_publicacao(site: Path, dados: dict) -> None:
    (site / "publicacao.json").write_text(json.dumps(dados, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def agora() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def copiar_conteudo(origem: Path, destino: Path) -> None:
    destino.mkdir(parents=True, exist_ok=True)
    for item in sorted(origem.iterdir()):
        alvo = destino / item.name
        if item.is_dir():
            shutil.copytree(item, alvo)
        else:
            shutil.copy2(item, alvo)


def publicar_oficial(site: Path, parte: Path, commit: str) -> None:
    validar_parte(parte)
    site.mkdir(parents=True, exist_ok=True)
    for item in site.iterdir():
        if item.name in PROTEGIDOS_NA_RAIZ:
            continue
        shutil.rmtree(item) if item.is_dir() else item.unlink()
    copiar_conteudo(parte, site)
    dados = ler_publicacao(site)
    dados["oficial"] = {"commit": commit, "publicado_em": agora()}
    salvar_publicacao(site, dados)
    finalizar(site)


def publicar_previa(site: Path, parte: Path, pr: int, commit: str, branch: str, titulo: str) -> None:
    validar_parte(parte)
    destino = site / "previews" / f"pr-{pr}"
    if destino.exists():
        shutil.rmtree(destino)
    copiar_conteudo(parte, destino)
    dados = ler_publicacao(site)
    dados.setdefault("previas", {})[str(pr)] = {
        "commit": commit, "branch": branch, "titulo": titulo, "publicado_em": agora(),
    }
    salvar_publicacao(site, dados)
    finalizar(site)


def remover_previa(site: Path, pr: int) -> bool:
    destino = site / "previews" / f"pr-{pr}"
    existia = destino.exists()
    if existia:
        shutil.rmtree(destino)
    dados = ler_publicacao(site)
    dados.setdefault("previas", {}).pop(str(pr), None)
    salvar_publicacao(site, dados)
    finalizar(site)
    return existia


def limpar_previas(site: Path, abertos: set[int]) -> list[int]:
    """Remove prévias de Pull Requests que não estão mais abertos."""
    removidas = []
    pasta = site / "previews"
    if pasta.is_dir():
        for item in sorted(pasta.iterdir()):
            m = NOME_PREVIA.match(item.name)
            if item.is_dir() and m and int(m.group(1)) not in abertos:
                shutil.rmtree(item)
                removidas.append(int(m.group(1)))
    dados = ler_publicacao(site)
    for numero in list(dados.get("previas", {})):
        if int(numero) not in abertos:
            dados["previas"].pop(numero)
            if int(numero) not in removidas:
                removidas.append(int(numero))
    salvar_publicacao(site, dados)
    finalizar(site)
    return sorted(removidas)


def finalizar(site: Path) -> None:
    """Arquivos fixos do site: .nojekyll e a página com a lista de prévias."""
    (site / ".nojekyll").write_text("", encoding="utf-8")
    dados = ler_publicacao(site)
    previas = dados.get("previas", {})
    linhas = []
    for numero in sorted(previas, key=int):
        p = previas[numero]
        linhas.append(
            f'<li><a href="pr-{numero}/"><strong>PR #{numero}</strong></a> — {html.escape(p.get("titulo") or "")}'
            f'<br><small>branch <code>{html.escape(p.get("branch", ""))}</code> · commit <code>{html.escape(p.get("commit", "")[:7])}</code>'
            f' · <a href="pr-{numero}/wiki/">Wiki da prévia</a></small></li>'
        )
    lista = "<ul>" + "".join(linhas) + "</ul>" if linhas else "<p>Nenhuma prévia aberta no momento.</p>"
    oficial = dados.get("oficial") or {}
    pagina = f"""<!DOCTYPE html>
<html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Prévias · Crônicas de Eudora</title>
<style>body{{margin:0;padding:24px 18px;background:#121017;color:#ece9f3;font:17px/1.6 system-ui,sans-serif}}
main{{max-width:720px;margin:0 auto}}a{{color:#5ae6ff}}li{{margin:0 0 14px}}code{{background:#241f30;padding:1px 5px;border-radius:5px}}
small{{color:#aba5ba}}</style></head>
<body><main>
<h1>Prévias em teste</h1>
<p>Versões candidatas de cada Pull Request aberto. Elas <strong>não</strong> são a versão oficial.</p>
{lista}
<p><a href="../">Jogo oficial</a> · <a href="../wiki/">Wiki oficial</a>{f" · commit oficial <code>{html.escape(oficial.get('commit', '')[:7])}</code>" if oficial.get("commit") else ""}</p>
</main></body></html>
"""
    (site / "previews").mkdir(parents=True, exist_ok=True)
    (site / "previews" / "index.html").write_text(pagina, encoding="utf-8")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Monta o site publicado (jogo, Wiki e prévias).")
    parser.add_argument("acao", choices=["oficial", "previa", "remover", "limpar", "oficial-atual"])
    parser.add_argument("--site", required=True)
    parser.add_argument("--parte")
    parser.add_argument("--pr", type=int)
    parser.add_argument("--commit", default="")
    parser.add_argument("--branch", default="")
    parser.add_argument("--titulo", default="")
    parser.add_argument("--abertos", default="")
    a = parser.parse_args(argv)
    site = Path(a.site)
    try:
        if a.acao == "oficial":
            publicar_oficial(site, Path(a.parte), a.commit)
            print(f"Jogo e Wiki oficiais publicados (commit {a.commit[:7]}).")
        elif a.acao == "previa":
            if not a.pr:
                raise ErroMontagem("--pr é obrigatório")
            publicar_previa(site, Path(a.parte), a.pr, a.commit, a.branch, a.titulo)
            print(f"Prévia do PR #{a.pr} publicada em previews/pr-{a.pr}/ (commit {a.commit[:7]}).")
        elif a.acao == "remover":
            existia = remover_previa(site, a.pr)
            print(f"Prévia do PR #{a.pr} {'removida' if existia else 'não existia'}.")
        elif a.acao == "limpar":
            abertos = {int(x) for x in a.abertos.split()} if a.abertos.strip() else set()
            removidas = limpar_previas(site, abertos)
            print("Prévias removidas: " + (", ".join(f"#{n}" for n in removidas) if removidas else "nenhuma"))
        elif a.acao == "oficial-atual":
            print((ler_publicacao(site).get("oficial") or {}).get("commit", ""))
    except ErroMontagem as erro:
        print(f"ERRO: {erro}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
