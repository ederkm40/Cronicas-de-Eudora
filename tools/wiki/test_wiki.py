"""Testes da Wiki (python3 -m unittest discover -s tools -p "test_*.py").

Gera a Wiki de verdade a partir de wiki-src/ e docs/ e confere: geração sem erros, links internos,
busca, resultado determinístico, modo prévia e as falhas esperadas para fontes com erro.
"""

import hashlib
import html.parser
import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from urllib.parse import unquote, urlsplit

AQUI = Path(__file__).resolve().parent
RAIZ = AQUI.parents[1]
sys.path.insert(0, str(AQUI))
import build_wiki  # noqa: E402
import markdown_mini  # noqa: E402


class Links(html.parser.HTMLParser):
    def __init__(self):
        super().__init__()
        self.links, self.ids = [], set()

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if "id" in a:
            self.ids.add(a["id"])
        for chave in ("href", "src", "action"):
            if a.get(chave):
                self.links.append((tag, a[chave]))


def gerar(saida: Path, *extra: str, fonte: Path | None = None) -> int:
    args = ["--saida", str(saida)] + list(extra)
    if fonte:
        args += ["--fonte", str(fonte)]
    return build_wiki.main(args)


def hash_pasta(pasta: Path) -> str:
    h = hashlib.sha256()
    for arquivo in sorted(pasta.rglob("*")):
        if arquivo.is_file():
            h.update(arquivo.relative_to(pasta).as_posix().encode())
            h.update(arquivo.read_bytes())
    return h.hexdigest()


class TestWiki(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tmp = tempfile.TemporaryDirectory()
        cls.saida = Path(cls.tmp.name) / "wiki"
        assert gerar(cls.saida) == 0, "a Wiki deveria ser gerada sem erros"

    @classmethod
    def tearDownClass(cls):
        cls.tmp.cleanup()

    def test_paginas_principais_existem(self):
        for caminho in ["index.html", "busca/index.html", "melhorias/poder-arcano/index.html",
                        "desenvolvimento/index.html", "desenvolvimento/changelog/index.html",
                        "desenvolvimento/relatorios/0.2-alpha/index.html", "search-index.json",
                        "assets/wiki.css", "assets/busca.js", "assets/logo.svg"]:
            self.assertTrue((self.saida / caminho).is_file(), caminho)
        site = json.loads((RAIZ / "wiki-src/site.json").read_text(encoding="utf-8"))
        self.assertEqual(len(site["categorias"]), 12)
        for cat in site["categorias"]:
            self.assertTrue((self.saida / cat["id"] / "index.html").is_file(), cat["id"])

    def test_todos_os_links_internos_funcionam(self):
        quebrados = []
        for pagina in self.saida.rglob("*.html"):
            parser = Links()
            parser.feed(pagina.read_text(encoding="utf-8"))
            for tag, link in parser.links:
                partes = urlsplit(link)
                if partes.scheme or link.startswith(("mailto:", "//")):
                    continue
                if partes.path == "":
                    if partes.fragment and partes.fragment not in parser.ids:
                        quebrados.append(f"{pagina}: âncora #{partes.fragment}")
                    continue
                alvo = (pagina.parent / unquote(partes.path)).resolve()
                if alvo.is_dir():
                    alvo = alvo / "index.html"
                dentro = self.saida.resolve() in alvo.parents or alvo == self.saida.resolve()
                if not dentro:
                    # Só "Jogar" (../ a partir da raiz da Wiki) pode sair da pasta da Wiki.
                    self.assertTrue(alvo.parent == self.saida.resolve().parent, f"{pagina}: {link} sai da Wiki")
                    continue
                if not alvo.is_file():
                    quebrados.append(f"{pagina.relative_to(self.saida)}: {link}")
        self.assertEqual(quebrados, [])

    def test_indice_de_busca(self):
        indice = json.loads((self.saida / "search-index.json").read_text(encoding="utf-8"))
        titulos = {item["t"] for item in indice}
        for esperado in ["Poder arcano", "Cadência", "Núcleo vital", "Passos ligeiros", "Projétil adicional",
                         "Campo de ruptura", "Joystick flutuante", "Orbes de experiência", "Level-up"]:
            self.assertIn(esperado, titulos)
        for item in indice:
            alvo = self.saida / item["u"] / "index.html" if item["u"] else self.saida / "index.html"
            self.assertTrue(alvo.is_file(), item["u"])

    # No CI, EXIGIR_NODE=1 transforma a falta do Node em falha (em vez de pular em silêncio).
    @unittest.skipUnless(shutil.which("node") or os.environ.get("EXIGIR_NODE") == "1", "Node.js não disponível")
    def test_busca_no_javascript(self):
        if not shutil.which("node"):
            self.fail("EXIGIR_NODE=1, mas o Node.js não foi encontrado")
        script = f"""
        const b = require({json.dumps(str(RAIZ / 'wiki-src/assets/busca.js'))});
        const indice = require({json.dumps(str(self.saida / 'search-index.json'))});
        const r = (q) => b.buscar(indice, q).map(i => i.t);
        console.log(JSON.stringify({{
          semAcento: r("nucleo vital")[0], comAcento: r("Núcleo")[0], dois: r("orbe ima").length > 0,
          nada: r("xyzinexistente").length, vazio: r("   ").length, titulo: r("cadencia")[0]
        }}));
        """
        saida = subprocess.run(["node", "-e", script], capture_output=True, text=True, check=True).stdout
        r = json.loads(saida)
        self.assertEqual(r["semAcento"], "Núcleo vital")
        self.assertEqual(r["comAcento"], "Núcleo vital")
        self.assertTrue(r["dois"])
        self.assertEqual(r["nada"], 0)
        self.assertEqual(r["vazio"], 0)
        self.assertEqual(r["titulo"], "Cadência")

    def test_geracao_deterministica(self):
        outra = Path(self.tmp.name) / "wiki-2"
        self.assertEqual(gerar(outra), 0)
        self.assertEqual(hash_pasta(self.saida), hash_pasta(outra))

    def test_fontes_nao_sao_alteradas(self):
        antes = hash_pasta(RAIZ / "wiki-src")
        self.assertEqual(gerar(Path(self.tmp.name) / "wiki-3"), 0)
        self.assertEqual(hash_pasta(RAIZ / "wiki-src"), antes)

    def test_modo_previa_mostra_aviso(self):
        saida = Path(self.tmp.name) / "previa"
        self.assertEqual(gerar(saida, "--canal", "previa", "--pr", "12", "--commit", "abcdef1234", "--branch", "etapa-x"), 0)
        inicio = (saida / "index.html").read_text(encoding="utf-8")
        self.assertIn("Prévia em teste", inicio)
        self.assertIn("Pull Request #12", inicio)
        self.assertIn("abcdef1", inicio)
        self.assertNotIn("Prévia em teste", (self.saida / "index.html").read_text(encoding="utf-8"))

    def test_estados_e_aviso_de_graficos(self):
        inicio = (self.saida / "index.html").read_text(encoding="utf-8")
        self.assertIn('class="selo selo-publicado"', inicio)
        self.assertIn("provisórios", inicio)
        self.assertIn('href="../"', inicio, "o botão Jogar deve levar ao jogo")

    def _fonte_com(self, arquivo: str, conteudo: str) -> Path:
        fonte = Path(self.tmp.name) / f"fonte-{abs(hash(conteudo))}"
        shutil.copytree(RAIZ / "wiki-src", fonte)
        destino = fonte / arquivo
        destino.parent.mkdir(parents=True, exist_ok=True)
        destino.write_text(conteudo, encoding="utf-8")
        return fonte

    def test_link_quebrado_falha(self):
        fonte = self._fonte_com("armas/teste.md", "---\ntitulo: Teste\n---\nVeja [[armas/nao-existe]].\n")
        self.assertEqual(gerar(Path(self.tmp.name) / "x1", fonte=fonte), 1)

    def test_estado_desconhecido_falha(self):
        fonte = self._fonte_com("armas/teste.md", "---\ntitulo: Teste\nestado: QUASE_PRONTO\n---\nTexto.\n")
        self.assertEqual(gerar(Path(self.tmp.name) / "x2", fonte=fonte), 1)

    def test_artigo_sem_titulo_falha(self):
        fonte = self._fonte_com("armas/teste.md", "---\nresumo: sem título\n---\nTexto.\n")
        self.assertEqual(gerar(Path(self.tmp.name) / "x3", fonte=fonte), 1)

    def test_novo_artigo_aparece_na_categoria_e_na_busca(self):
        fonte = self._fonte_com("armas/teste-novo.md", "---\ntitulo: Arma de teste\nresumo: Só para teste.\nestado: PLANEJADO\n---\nTexto.\n")
        saida = Path(self.tmp.name) / "x4"
        self.assertEqual(gerar(saida, fonte=fonte), 0)
        self.assertIn("Arma de teste", (saida / "armas/index.html").read_text(encoding="utf-8"))
        self.assertIn("Arma de teste", (saida / "search-index.json").read_text(encoding="utf-8"))


class TestMarkdown(unittest.TestCase):
    def test_elementos(self):
        corpo, titulos = markdown_mini.convert(
            "# Título\n\nTexto **forte** e *leve* com `código`.\n\n- a\n- b\n    - b1\n\n1. um\n2. dois\n\n"
            "| A | B |\n|---|---|\n| [[x\\|y]] | 2 |\n\n> nota\n\n---\n\n```\n<cru>\n```\n"
        )
        self.assertIn("<h1 id=\"titulo\">Título</h1>", corpo)
        self.assertIn("<strong>forte</strong>", corpo)
        self.assertIn("<em>leve</em>", corpo)
        self.assertIn("<code>código</code>", corpo)
        self.assertIn("<ul><li>a</li><li>b<ul><li>b1</li></ul></li></ul>", corpo)
        self.assertIn("<ol><li>um</li><li>dois</li></ol>", corpo)
        self.assertIn("<td>[[x|y]]</td>", corpo, "pipe escapado não divide a célula")
        self.assertIn("<blockquote>", corpo)
        self.assertIn("&lt;cru&gt;", corpo, "código é escapado")
        self.assertEqual(titulos[0][0], 1)

    def test_html_e_escapado(self):
        corpo, _ = markdown_mini.convert("Texto <script>alert(1)</script>")
        self.assertNotIn("<script>", corpo)


if __name__ == "__main__":
    unittest.main()
