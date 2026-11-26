"""Testes da montagem do site (python3 -m unittest discover -s tools -p "test_*.py")."""

import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import montar_site as ms  # noqa: E402


def criar_parte(base: Path, marca: str) -> Path:
    """Uma exportação falsa: os 4 arquivos do Godot + Wiki, com uma marca para identificar a origem."""
    base.mkdir(parents=True)
    for nome in ms.ARQUIVOS_JOGO:
        (base / nome).write_text(f"{nome} {marca}")
    (base / "wiki").mkdir()
    (base / "wiki" / "index.html").write_text(f"wiki {marca}")
    return base


class TestMontarSite(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.raiz = Path(self.tmp.name)
        self.site = self.raiz / "site"
        self.site.mkdir()
        (self.site / ".git").mkdir()
        (self.site / ".git" / "HEAD").write_text("ref")

    def tearDown(self):
        self.tmp.cleanup()

    def ler(self, caminho):
        return (self.site / caminho).read_text()

    def test_oficial_publica_jogo_e_wiki_na_raiz(self):
        ms.publicar_oficial(self.site, criar_parte(self.raiz / "main", "main-1"), "aaa1111")
        for nome in ms.ARQUIVOS_JOGO:
            self.assertEqual(self.ler(nome), f"{nome} main-1")
        self.assertEqual(self.ler("wiki/index.html"), "wiki main-1")
        self.assertTrue((self.site / ".nojekyll").exists())
        self.assertEqual(ms.ler_publicacao(self.site)["oficial"]["commit"], "aaa1111")

    def test_previa_nao_substitui_o_oficial(self):
        ms.publicar_oficial(self.site, criar_parte(self.raiz / "main", "main-1"), "aaa1111")
        ms.publicar_previa(self.site, criar_parte(self.raiz / "pr", "pr-7"), 7, "bbb2222", "etapa-x", "Etapa X")
        self.assertEqual(self.ler("index.html"), "index.html main-1")
        self.assertEqual(self.ler("wiki/index.html"), "wiki main-1")
        self.assertEqual(self.ler("previews/pr-7/index.wasm"), "index.wasm pr-7")
        self.assertEqual(self.ler("previews/pr-7/wiki/index.html"), "wiki pr-7")
        self.assertIn("PR #7", self.ler("previews/index.html"))

    def test_oficial_novo_preserva_previas_e_git(self):
        ms.publicar_oficial(self.site, criar_parte(self.raiz / "m1", "main-1"), "aaa1111")
        ms.publicar_previa(self.site, criar_parte(self.raiz / "pr", "pr-7"), 7, "bbb2222", "etapa-x", "")
        (self.site / "arquivo-antigo.txt").write_text("sobra de versão antiga")
        ms.publicar_oficial(self.site, criar_parte(self.raiz / "m2", "main-2"), "ccc3333")
        self.assertEqual(self.ler("index.html"), "index.html main-2")
        self.assertFalse((self.site / "arquivo-antigo.txt").exists(), "arquivos velhos da raiz devem sair")
        self.assertEqual(self.ler("previews/pr-7/index.html"), "index.html pr-7")
        self.assertEqual(self.ler(".git/HEAD"), "ref")
        dados = ms.ler_publicacao(self.site)
        self.assertEqual(dados["oficial"]["commit"], "ccc3333")
        self.assertIn("7", dados["previas"])

    def test_novo_push_atualiza_a_previa(self):
        ms.publicar_previa(self.site, criar_parte(self.raiz / "p1", "push-1"), 7, "bbb2222", "x", "")
        (self.site / "previews/pr-7/sobra.txt").write_text("velho")
        ms.publicar_previa(self.site, criar_parte(self.raiz / "p2", "push-2"), 7, "ddd4444", "x", "")
        self.assertEqual(self.ler("previews/pr-7/index.pck"), "index.pck push-2")
        self.assertFalse((self.site / "previews/pr-7/sobra.txt").exists())
        self.assertEqual(ms.ler_publicacao(self.site)["previas"]["7"]["commit"], "ddd4444")

    def test_remover_e_limpar_previas(self):
        ms.publicar_oficial(self.site, criar_parte(self.raiz / "main", "main-1"), "aaa1111")
        for n in (3, 5, 8):
            ms.publicar_previa(self.site, criar_parte(self.raiz / f"p{n}", f"pr-{n}"), n, f"sha{n}", "b", "")
        self.assertTrue(ms.remover_previa(self.site, 5))
        self.assertFalse((self.site / "previews/pr-5").exists())
        self.assertFalse(ms.remover_previa(self.site, 5), "remover de novo não é erro")
        removidas = ms.limpar_previas(self.site, {8})
        self.assertEqual(removidas, [3])
        self.assertTrue((self.site / "previews/pr-8").exists())
        self.assertEqual(sorted(ms.ler_publicacao(self.site)["previas"]), ["8"])
        self.assertEqual(self.ler("index.html"), "index.html main-1", "limpar não mexe no oficial")
        self.assertNotIn("PR #3", self.ler("previews/index.html"))

    def test_exportacao_incompleta_e_recusada(self):
        parte = criar_parte(self.raiz / "ruim", "x")
        (parte / "index.wasm").unlink()
        with self.assertRaises(ms.ErroMontagem):
            ms.publicar_previa(self.site, parte, 9, "s", "b", "")
        self.assertFalse((self.site / "previews/pr-9").exists())

    def test_linha_de_comando(self):
        parte = criar_parte(self.raiz / "main", "main-1")
        self.assertEqual(ms.main(["oficial", "--site", str(self.site), "--parte", str(parte), "--commit", "abc"]), 0)
        self.assertEqual(ms.main(["previa", "--site", str(self.site), "--parte", str(parte), "--pr", "4", "--commit", "d"]), 0)
        self.assertEqual(ms.main(["limpar", "--site", str(self.site), "--abertos", ""]), 0)
        self.assertFalse((self.site / "previews/pr-4").exists())
        dados = json.loads(self.ler("publicacao.json"))
        self.assertEqual(dados["previas"], {})


if __name__ == "__main__":
    unittest.main()
