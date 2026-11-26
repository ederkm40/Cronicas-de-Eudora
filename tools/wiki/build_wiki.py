#!/usr/bin/env python3
"""Gerador estático da Wiki de Crônicas de Eudora.

Só usa a biblioteca padrão do Python 3. Sem internet, sem banco de dados, sem CDN.

Uso:
  python3 tools/wiki/build_wiki.py --saida build/wiki
  python3 tools/wiki/build_wiki.py --saida build/site/previews/pr-7/wiki --canal previa --pr 7 \\
      --commit abc1234 --branch etapa-x

Entradas (nunca são alteradas):
  wiki-src/site.json      nome, versão oficial e lista de categorias
  wiki-src/**/*.md        artigos (um arquivo por página)
  wiki-src/assets/*       CSS, JavaScript da busca e logotipo
  docs/CHANGELOG.md, docs/versoes/*/RELATORIO.md, docs/decisoes/*.md
                          viram páginas somente leitura do painel de desenvolvimento

Saída: a pasta de --saida é apagada e recriada. Mesmas entradas = mesmos arquivos (determinístico).

Erros que interrompem a geração (código de saída 1): link interno quebrado, artigo sem título,
estado desconhecido, diretiva desconhecida, categoria sem página.
"""

from __future__ import annotations

import argparse
import html
import json
import os
import posixpath
import re
import shutil
import sys
from dataclasses import dataclass, field
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import markdown_mini  # noqa: E402

ESTADOS = {
    "PLANEJADO": "Planejado",
    "EM_DESENVOLVIMENTO": "Em desenvolvimento",
    "IMPLEMENTADO": "Implementado",
    "TESTADO": "Testado",
    "PUBLICADO": "Publicado",
}
REPO_URL = "https://github.com/ederkm40/Cronicas-de-Eudora"
SITE_URL = "https://ederkm40.github.io/Cronicas-de-Eudora/"

_WIKILINK = re.compile(r"\[\[([^\]|#]+)(#[^\]|]+)?(?:\|([^\]]+))?\]\]")
_ESTADO = re.compile(r"\{([A-Z_]{4,})\}")
_DIRETIVA = re.compile(r"^\{\{\s*([a-z_]+)(?::([a-z0-9_\-/]+))?\s*\}\}$")


class ErroWiki(Exception):
    pass


@dataclass
class Pagina:
    id: str  # "" para a página inicial, "melhorias", "melhorias/poder-arcano"
    titulo: str
    corpo: str
    meta: dict = field(default_factory=dict)
    origem: str = ""  # caminho do arquivo-fonte, relativo à raiz do repositório
    somente_leitura: bool = False  # páginas que vêm de docs/

    @property
    def saida(self) -> str:
        return "index.html" if self.id == "" else f"{self.id}/index.html"

    @property
    def pasta(self) -> str:
        return self.id

    @property
    def categoria(self) -> str:
        return self.id.split("/")[0] if self.id else ""


# ---------------------------------------------------------------- leitura

def ler_front_matter(texto: str, origem: str) -> tuple[dict, str]:
    meta: dict = {}
    if texto.startswith("---\n"):
        fim = texto.find("\n---", 4)
        if fim == -1:
            raise ErroWiki(f"{origem}: cabeçalho '---' sem fechamento")
        for linha in texto[4:fim].splitlines():
            if not linha.strip() or linha.strip().startswith("#"):
                continue
            if ":" not in linha:
                raise ErroWiki(f"{origem}: linha inválida no cabeçalho: {linha!r}")
            chave, valor = linha.split(":", 1)
            meta[chave.strip()] = valor.strip()
        texto = texto[fim + 4:].lstrip("\n")
    return meta, texto


def carregar_paginas(src: Path, raiz: Path) -> dict[str, Pagina]:
    paginas: dict[str, Pagina] = {}
    for arquivo in sorted(src.rglob("*.md")):
        rel = arquivo.relative_to(src).as_posix()
        if rel.startswith("assets/") or Path(rel).name.startswith("_") or Path(rel).name == "README.md":
            continue
        meta, corpo = ler_front_matter(arquivo.read_text(encoding="utf-8"), rel)
        if not meta.get("titulo"):
            raise ErroWiki(f"wiki-src/{rel}: falta 'titulo:' no cabeçalho")
        estado = meta.get("estado", "")
        if estado and estado not in ESTADOS:
            raise ErroWiki(f"wiki-src/{rel}: estado desconhecido '{estado}' (use {', '.join(ESTADOS)})")
        pid = rel[:-3]
        if pid == "index":
            pid = ""
        elif pid.endswith("/index"):
            pid = pid[: -len("/index")]
        paginas[pid] = Pagina(pid, meta["titulo"], corpo, meta, caminho_relativo(arquivo, raiz))
    return paginas


def caminho_relativo(arquivo: Path, raiz: Path) -> str:
    try:
        return arquivo.resolve().relative_to(raiz).as_posix()
    except ValueError:
        return arquivo.name


def carregar_docs(docs: Path, raiz: Path) -> dict[str, Pagina]:
    """Changelog, relatórios e decisões técnicas: páginas somente leitura vindas de docs/."""
    paginas: dict[str, Pagina] = {}

    def adicionar(pid: str, arquivo: Path, titulo_padrao: str, extra: dict | None = None) -> None:
        texto = arquivo.read_text(encoding="utf-8")
        meta, corpo = ler_front_matter(texto, arquivo.name)
        primeira = re.match(r"#\s+(.+)\n", corpo)
        titulo = meta.get("titulo") or (primeira.group(1).strip() if primeira else titulo_padrao)
        if primeira:
            corpo = corpo[primeira.end():]
        meta.update(extra or {})
        paginas[pid] = Pagina(pid, titulo, corpo, meta, caminho_relativo(arquivo, raiz), True)

    changelog = docs / "CHANGELOG.md"
    if changelog.exists():
        adicionar("desenvolvimento/changelog", changelog, "Changelog")
    for rel in sorted((docs / "versoes").glob("*/RELATORIO.md")) if (docs / "versoes").exists() else []:
        versao = rel.parent.name
        adicionar(f"desenvolvimento/relatorios/{versao}", rel, f"Relatório {versao}", {"versao": versao})
    for dec in sorted((docs / "decisoes").glob("*.md")) if (docs / "decisoes").exists() else []:
        if dec.name == "README.md":
            continue
        adicionar(f"desenvolvimento/decisoes/{dec.stem}", dec, dec.stem)
    return paginas


# ---------------------------------------------------------------- links e conteúdo

def rel_url(de: Pagina | str, para_id: str, ancora: str = "") -> str:
    """Endereço relativo de uma página para outra (funciona em /wiki/ e em /previews/pr-N/wiki/)."""
    origem = de.pasta if isinstance(de, Pagina) else de
    destino = para_id
    caminho = posixpath.relpath(destino or ".", origem or ".")
    caminho = "./" if caminho == "." else caminho + "/"
    return caminho + ancora


def raiz_rel(pagina: Pagina) -> str:
    caminho = posixpath.relpath(".", pagina.pasta or ".")
    return "" if caminho == "." else caminho + "/"


class Gerador:
    def __init__(self, src: Path, docs: Path, raiz: Path, opcoes: argparse.Namespace):
        self.src = src
        self.raiz = raiz
        self.opcoes = opcoes
        self.site = json.loads((src / "site.json").read_text(encoding="utf-8"))
        self.paginas = carregar_paginas(src, raiz)
        self.paginas.update(carregar_docs(docs, raiz))
        self.categorias = self.site["categorias"]
        for cat in self.categorias + self.site.get("areas", []):
            if cat["id"] not in self.paginas:
                raise ErroWiki(f"a categoria '{cat['id']}' precisa de wiki-src/{cat['id']}/index.md")
        self.erros: list[str] = []
        self.ref = opcoes.branch or "main"

    # ---- links internos e estados (chamado pelo conversor, linha a linha)
    def hook_para(self, pagina: Pagina):
        def hook(texto: str, guardar) -> str:
            def wikilink(m: re.Match) -> str:
                alvo = m.group(1).strip().strip("/")
                ancora = m.group(2) or ""
                if alvo == "inicio":
                    alvo = ""
                if alvo not in self.paginas:
                    self.erros.append(f"{pagina.origem}: link quebrado [[{m.group(1)}]]")
                    return guardar(html.escape(m.group(3) or m.group(1)))
                rotulo = m.group(3) or self.paginas[alvo].titulo
                url = rel_url(pagina, alvo, ancora)
                return guardar(f'<a href="{html.escape(url)}">{html.escape(rotulo)}</a>')

            def estado(m: re.Match) -> str:
                nome = m.group(1)
                if nome not in ESTADOS:
                    self.erros.append(f"{pagina.origem}: estado desconhecido {{{nome}}}")
                    return m.group(0)
                return guardar(selo(nome))

            texto = texto.replace("\\|", "|")  # [[a\\|b]] também vale fora de tabelas
            texto = _WIKILINK.sub(wikilink, texto)
            texto = _ESTADO.sub(estado, texto)
            if pagina.somente_leitura:
                texto = self._links_de_docs(pagina, texto, guardar)
            else:
                for m in re.finditer(r"\]\((?!https?://|#|mailto:)([^)]+)\)", texto):
                    self.erros.append(f"{pagina.origem}: use [[caminho]] para links internos, não ({m.group(1)})")
            return texto

        return hook

    def _links_de_docs(self, pagina: Pagina, texto: str, guardar) -> str:
        """Em páginas vindas de docs/, links relativos apontam para o arquivo no GitHub."""
        base = posixpath.dirname(pagina.origem)

        def trocar(m: re.Match) -> str:
            rotulo, alvo = m.group(1), m.group(2)
            if alvo.startswith(("http://", "https://", "#", "mailto:")):
                return m.group(0)
            caminho = posixpath.normpath(posixpath.join(base, alvo))
            url = f"{REPO_URL}/blob/{self.ref}/{caminho}"
            return guardar(f'<a href="{html.escape(url)}" rel="noopener">{html.escape(rotulo)}</a>')

        return re.sub(r"\[([^\]]+)\]\(([^)\s]+)\)", trocar, texto)

    # ---- diretivas {{...}} em linha própria
    def diretiva(self, pagina: Pagina, nome: str, arg: str | None) -> str:
        if nome == "categorias":
            cards = []
            for cat in self.categorias:
                artigos = self.filhos(cat["id"])
                quantidade = f"{len(artigos)} artigo{'s' if len(artigos) != 1 else ''}" if artigos else "Em breve"
                cards.append(
                    f'<a class="cartao-cat" href="{rel_url(pagina, cat["id"])}">'
                    f'<span class="cat-icone" aria-hidden="true">{html.escape(cat.get("icone", ""))}</span>'
                    f'<span class="cat-nome">{html.escape(cat["titulo"])}</span>'
                    f'<span class="cat-desc">{html.escape(cat.get("descricao", ""))}</span>'
                    f'<span class="cat-qtd">{quantidade}</span></a>'
                )
            return '<div class="grade-cat">' + "".join(cards) + "</div>"
        if nome == "artigos":
            pasta = arg or pagina.id
            artigos = self.filhos(pasta)
            if not artigos:
                return '<p class="vazio">Nenhum artigo nesta categoria ainda. O conteúdo aparece aqui quando existir no jogo.</p>'
            itens = []
            for art in artigos:
                resumo = html.escape(art.meta.get("resumo", ""))
                est = selo(art.meta["estado"]) if art.meta.get("estado") else ""
                itens.append(
                    f'<li><a href="{rel_url(pagina, art.id)}">{html.escape(art.titulo)}</a> {est}'
                    + (f'<span class="resumo">{resumo}</span>' if resumo else "")
                    + "</li>"
                )
            return '<ul class="lista-artigos">' + "".join(itens) + "</ul>"
        if nome in ("relatorios", "decisoes"):
            prefixo = f"desenvolvimento/{nome}/"
            itens = sorted((p for p in self.paginas.values() if p.id.startswith(prefixo)), key=lambda p: p.id, reverse=(nome == "relatorios"))
            if not itens:
                return '<p class="vazio">Nada registrado ainda.</p>'
            return '<ul class="lista-artigos">' + "".join(
                f'<li><a href="{rel_url(pagina, p.id)}">{html.escape(p.titulo)}</a></li>' for p in itens
            ) + "</ul>"
        if nome == "jogar":
            return (
                f'<p class="cta"><a class="botao-jogar" href="{raiz_rel(pagina)}../">Jogar agora no navegador</a>'
                '<span class="cta-nota">Funciona no celular e no computador. Gráficos provisórios.</span></p>'
            )
        self.erros.append(f"{pagina.origem}: diretiva desconhecida {{{{{nome}}}}}")
        return ""

    def filhos(self, pasta: str) -> list[Pagina]:
        prefixo = pasta + "/"
        artigos = [p for p in self.paginas.values() if p.id.startswith(prefixo) and "/" not in p.id[len(prefixo):] and not p.somente_leitura]
        return sorted(artigos, key=lambda p: (int(p.meta.get("ordem", "100")), p.titulo))

    def renderizar_corpo(self, pagina: Pagina) -> tuple[str, list]:
        hook = self.hook_para(pagina)
        partes, bloco, titulos = [], [], []
        for linha in pagina.corpo.split("\n"):
            m = _DIRETIVA.match(linha.strip())
            if m:
                if bloco:
                    corpo, t = markdown_mini.convert("\n".join(bloco), hook)
                    partes.append(corpo)
                    titulos += t
                    bloco = []
                partes.append(self.diretiva(pagina, m.group(1), m.group(2)))
            else:
                bloco.append(linha)
        if bloco:
            corpo, t = markdown_mini.convert("\n".join(bloco), hook)
            partes.append(corpo)
            titulos += t
        return "\n".join(partes), titulos

    # ---- página completa
    def montar_html(self, pagina: Pagina) -> str:
        corpo, titulos = self.renderizar_corpo(pagina)
        raiz = raiz_rel(pagina)
        nome = self.site["nome"]
        titulo_aba = nome + " — Wiki" if pagina.id == "" else f"{pagina.titulo} · {nome} Wiki"

        trilha = [f'<a href="{rel_url(pagina, "")}">Wiki</a>']
        partes = pagina.id.split("/") if pagina.id else []
        for n in range(1, len(partes)):
            pid = "/".join(partes[:n])
            if pid in self.paginas:
                trilha.append(f'<a href="{rel_url(pagina, pid)}">{html.escape(self.paginas[pid].titulo)}</a>')
        trilha_html = (
            '<nav class="trilha" aria-label="Você está em">' + " › ".join(trilha) + "</nav>" if pagina.id else ""
        )

        selos = ""
        if pagina.meta.get("estado"):
            selos += selo(pagina.meta["estado"])
        if pagina.meta.get("versao"):
            selos += f'<span class="versao-art">Desde a {html.escape(pagina.meta["versao"])}</span>'

        sumario = ""
        h2 = [t for t in titulos if t[0] == 2]
        if len(h2) >= 3:
            sumario = '<details class="sumario" open><summary>Nesta página</summary><ol>' + "".join(
                f'<li><a href="#{a}">{html.escape(re.sub(r"[`*]", "", t))}</a></li>' for _, t, a in h2
            ) + "</ol></details>"

        menu = "".join(
            f'<li><a href="{rel_url(pagina, c["id"])}"{" aria-current=page" if pagina.categoria == c["id"] else ""}>'
            f'{html.escape(c["titulo"])}</a></li>'
            for c in self.categorias
        )
        areas = "".join(
            f'<li><a href="{rel_url(pagina, a["id"])}"{" aria-current=page" if pagina.categoria == a["id"] else ""}>'
            f'{html.escape(a["titulo"])}</a></li>'
            for a in self.site.get("areas", [])
        )

        o = self.opcoes
        aviso = ""
        if o.canal == "previa":
            aviso = (
                '<div class="aviso-previa" role="note"><strong>Prévia em teste</strong> — '
                + (f"Pull Request #{html.escape(str(o.pr))}, " if o.pr else "")
                + (f"branch <code>{html.escape(o.branch)}</code>, " if o.branch else "")
                + (f"commit <code>{html.escape(o.commit[:7])}</code>. " if o.commit else "")
                + f'Esta não é a versão oficial. <a href="{SITE_URL}wiki/">Ir para a Wiki oficial</a></div>'
            )

        fonte = (
            f'<a href="{REPO_URL}/blob/{html.escape(self.ref)}/{html.escape(pagina.origem)}" rel="noopener">'
            + ("Ver o documento de origem" if pagina.somente_leitura else "Editar esta página no GitHub")
            + "</a>"
            if pagina.origem
            else ""
        )
        canal = "Prévia" if o.canal == "previa" else "Oficial"
        commit = f" · commit {html.escape(o.commit[:7])}" if o.commit else ""

        return f"""<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{html.escape(titulo_aba)}</title>
<meta name="description" content="{html.escape(pagina.meta.get('resumo', self.site.get('descricao', '')))}">
<link rel="icon" href="{raiz}assets/logo.svg" type="image/svg+xml">
<link rel="stylesheet" href="{raiz}assets/wiki.css">
</head>
<body data-raiz="{raiz}">
{aviso}
<header class="topo">
  <a class="marca" href="{rel_url(pagina, '')}"><img src="{raiz}assets/logo.svg" alt="" width="32" height="32"><span>{html.escape(nome)}<small>Wiki</small></span></a>
  <form class="busca" action="{rel_url(pagina, 'busca')}" method="get" role="search">
    <input type="search" name="q" placeholder="Buscar na Wiki" aria-label="Buscar na Wiki">
  </form>
  <a class="botao-topo" href="{raiz}../">Jogar</a>
</header>
<div class="layout">
<nav class="menu" aria-label="Categorias">
  <details class="menu-movel"><summary>Categorias</summary>
  <ul>{menu}</ul>
  <p class="menu-titulo">Projeto</p>
  <ul>{areas}</ul>
  </details>
  <div class="menu-fixo">
  <p class="menu-titulo">Enciclopédia</p>
  <ul>{menu}</ul>
  <p class="menu-titulo">Projeto</p>
  <ul>{areas}</ul>
  </div>
</nav>
<main>
{trilha_html}
<article>
<h1>{html.escape(pagina.titulo)}</h1>
{f'<p class="selos">{selos}</p>' if selos else ''}
{sumario}
{corpo}
</article>
</main>
</div>
<footer class="rodape">
  <p>{html.escape(nome)} · versão oficial {html.escape(self.site['versao_oficial'])} “{html.escape(self.site['nome_versao'])}” · Wiki {canal}{commit}</p>
  <p>Gráficos e textos do jogo são provisórios. {fonte}</p>
</footer>
<script src="{raiz}assets/busca.js" defer></script>
</body>
</html>
"""

    # ---- busca
    def indice_busca(self) -> list[dict]:
        itens = []
        for pid in sorted(self.paginas):
            p = self.paginas[pid]
            categoria = self.paginas[p.categoria].titulo if p.categoria in self.paginas and p.categoria != pid else ""
            itens.append({
                "t": p.titulo,
                "u": p.id + "/" if p.id else "",
                "c": categoria,
                "r": p.meta.get("resumo", ""),
                "x": markdown_mini.plain_text(p.corpo)[:4000],
            })
        return itens

    def gerar(self, saida: Path) -> list[str]:
        busca = Pagina("busca", "Busca", "", {"resumo": "Busca em todos os artigos da Wiki."})
        busca.corpo = "<!-- resultados preenchidos por assets/busca.js -->"
        self.paginas["busca"] = busca

        if saida.exists():
            shutil.rmtree(saida)
        saida.mkdir(parents=True)
        for pid in sorted(self.paginas):
            pagina = self.paginas[pid]
            destino = saida / pagina.saida
            destino.parent.mkdir(parents=True, exist_ok=True)
            documento = self.montar_html(pagina)
            if pid == "busca":
                documento = documento.replace(
                    "<p>&lt;!-- resultados preenchidos por assets/busca.js --&gt;</p>",
                    '<p id="busca-resumo" class="vazio">Digite um termo no campo de busca.</p><ol id="busca-resultados" class="resultados"></ol>'
                    '<noscript><p>A busca precisa de JavaScript. Use as categorias no menu.</p></noscript>',
                )
            destino.write_text(documento, encoding="utf-8")

        assets = saida / "assets"
        shutil.copytree(self.src / "assets", assets)
        (saida / "search-index.json").write_text(
            json.dumps(self.indice_busca(), ensure_ascii=False, sort_keys=True, separators=(",", ":")), encoding="utf-8"
        )
        info = {
            "canal": self.opcoes.canal, "pr": self.opcoes.pr, "commit": self.opcoes.commit,
            "branch": self.opcoes.branch, "paginas": len(self.paginas),
            "versao_oficial": self.site["versao_oficial"],
        }
        (saida / "wiki.json").write_text(json.dumps(info, ensure_ascii=False, sort_keys=True, indent=2), encoding="utf-8")
        return self.erros


def selo(estado: str) -> str:
    return f'<span class="selo selo-{estado.lower()}">{ESTADOS[estado]}</span>'


def main(argv: list[str] | None = None) -> int:
    raiz = Path(__file__).resolve().parents[2]
    parser = argparse.ArgumentParser(description="Gera a Wiki estática de Crônicas de Eudora.")
    parser.add_argument("--fonte", default=str(raiz / "wiki-src"))
    parser.add_argument("--docs", default=str(raiz / "docs"))
    parser.add_argument("--saida", default=str(raiz / "build" / "wiki"))
    parser.add_argument("--canal", choices=["oficial", "previa"], default="oficial")
    parser.add_argument("--pr", default="")
    parser.add_argument("--commit", default="")
    parser.add_argument("--branch", default="")
    opcoes = parser.parse_args(argv)
    # A raiz do projeto é a pasta acima de wiki-src (serve para montar os links "Editar no GitHub").
    raiz_projeto = Path(opcoes.fonte).resolve().parent
    try:
        gerador = Gerador(Path(opcoes.fonte), Path(opcoes.docs), raiz_projeto, opcoes)
        erros = gerador.gerar(Path(opcoes.saida))
    except ErroWiki as erro:
        print(f"ERRO: {erro}", file=sys.stderr)
        return 1
    if erros:
        for erro in erros:
            print(f"ERRO: {erro}", file=sys.stderr)
        return 1
    print(f"Wiki gerada: {len(gerador.paginas)} páginas em {opcoes.saida}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
