"""Conversor de Markdown simples para HTML, só com a biblioteca padrão do Python.

Suporta o necessário para a Wiki:
  # títulos (1 a 4), parágrafos, **negrito**, *itálico*, `código`, [texto](url),
  listas com - ou 1. (com subníveis por indentação), tabelas com |, > citação,
  --- linha horizontal e blocos ``` de código.

Links internos da Wiki ([[caminho]] ou [[caminho|texto]]) e marcadores de estado
({PLANEJADO} etc.) são resolvidos antes, pelo gerador (build_wiki.py), usando
a função `inline_hook`.
"""

from __future__ import annotations

import html
import re

_CODE_SPAN = re.compile(r"`([^`]+)`")
_LINK = re.compile(r"\[([^\]]+)\]\(([^)\s]+)\)")
_BOLD = re.compile(r"\*\*(.+?)\*\*")
_ITALIC = re.compile(r"(?<![\*\w])\*(?!\s)(.+?)(?<!\s)\*(?![\*\w])")
_HEADING = re.compile(r"^(#{1,4})\s+(.*)$")
_LIST_ITEM = re.compile(r"^(\s*)([-*]|\d+\.)\s+(.*)$")
_TABLE_SEP = re.compile(r"^\s*\|?\s*:?-{3,}:?\s*(\|\s*:?-{3,}:?\s*)*\|?\s*$")


def slugify(text: str) -> str:
    """Âncora estável para títulos: minúsculas, sem acentos, com hífens."""
    import unicodedata

    plain = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode()
    plain = re.sub(r"[^a-zA-Z0-9]+", "-", plain).strip("-").lower()
    return plain or "secao"


def inline(text: str, hook=None) -> str:
    """Formata uma linha: escapa HTML e aplica código, links, negrito e itálico."""
    placeholders: list[str] = []

    def keep(fragment: str) -> str:
        placeholders.append(fragment)
        return f"\x00{len(placeholders) - 1}\x00"

    text = _CODE_SPAN.sub(lambda m: keep(f"<code>{html.escape(m.group(1))}</code>"), text)
    if hook:
        text = hook(text, keep)
    text = _LINK.sub(lambda m: keep(_link(m.group(1), m.group(2), hook)), text)
    text = html.escape(text, quote=False)
    text = _BOLD.sub(r"<strong>\1</strong>", text)
    text = _ITALIC.sub(r"<em>\1</em>", text)
    while "\x00" in text:
        text = re.sub(r"\x00(\d+)\x00", lambda m: placeholders[int(m.group(1))], text)
    return text


def _link(label: str, url: str, hook) -> str:
    external = url.startswith(("http://", "https://"))
    attrs = ' rel="noopener"' if external else ""
    return f'<a href="{html.escape(url)}"{attrs}>{inline(label, hook)}</a>'


def convert(markdown: str, hook=None) -> tuple[str, list[tuple[int, str, str]]]:
    """Converte Markdown em HTML. Devolve (html, títulos) — títulos = [(nível, texto, âncora)]."""
    lines = markdown.replace("\r\n", "\n").split("\n")
    out: list[str] = []
    headings: list[tuple[int, str, str]] = []
    used_anchors: dict[str, int] = {}
    paragraph: list[str] = []
    i = 0

    def flush_paragraph() -> None:
        if paragraph:
            out.append("<p>" + inline(" ".join(s.strip() for s in paragraph), hook) + "</p>")
            paragraph.clear()

    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        if stripped.startswith("```"):
            flush_paragraph()
            lang = stripped[3:].strip()
            block: list[str] = []
            i += 1
            while i < len(lines) and not lines[i].strip().startswith("```"):
                block.append(lines[i])
                i += 1
            cls = f' class="lang-{html.escape(lang)}"' if lang else ""
            out.append(f"<pre><code{cls}>" + html.escape("\n".join(block)) + "</code></pre>")
            i += 1
            continue

        if not stripped:
            flush_paragraph()
            i += 1
            continue

        heading = _HEADING.match(stripped)
        if heading:
            flush_paragraph()
            level = len(heading.group(1))
            title = heading.group(2).strip()
            anchor = slugify(re.sub(r"[`*\[\]{}]", "", title))
            count = used_anchors.get(anchor, 0)
            used_anchors[anchor] = count + 1
            if count:
                anchor = f"{anchor}-{count + 1}"
            headings.append((level, title, anchor))
            out.append(f'<h{level} id="{anchor}">{inline(title, hook)}</h{level}>')
            i += 1
            continue

        if re.fullmatch(r"-{3,}|\*{3,}", stripped):
            flush_paragraph()
            out.append("<hr>")
            i += 1
            continue

        if stripped.startswith(">"):
            flush_paragraph()
            quote: list[str] = []
            while i < len(lines) and lines[i].strip().startswith(">"):
                quote.append(lines[i].strip()[1:].lstrip())
                i += 1
            inner, _ = convert("\n".join(quote), hook)
            out.append(f"<blockquote>{inner}</blockquote>")
            continue

        if "|" in stripped and i + 1 < len(lines) and _TABLE_SEP.match(lines[i + 1]):
            flush_paragraph()
            header = _cells(stripped)
            aligns = [_align(c) for c in _cells(lines[i + 1])]
            i += 2
            rows: list[list[str]] = []
            while i < len(lines) and "|" in lines[i] and lines[i].strip():
                rows.append(_cells(lines[i]))
                i += 1
            out.append(_table(header, aligns, rows, hook))
            continue

        if _LIST_ITEM.match(line):
            flush_paragraph()
            block = []
            while i < len(lines) and (lines[i].strip() == "" or _LIST_ITEM.match(lines[i]) or lines[i].startswith("  ")):
                if lines[i].strip() == "":
                    # Uma linha vazia só continua a lista se a próxima for item do mesmo tipo.
                    proximo = _LIST_ITEM.match(lines[i + 1]) if i + 1 < len(lines) else None
                    primeiro = _LIST_ITEM.match(block[0])
                    if proximo and (proximo.group(2)[-1] == ".") == (primeiro.group(2)[-1] == "."):
                        i += 1
                        continue
                    break
                block.append(lines[i])
                i += 1
            out.append(_list(block, hook))
            continue

        paragraph.append(line)
        i += 1

    flush_paragraph()
    return "\n".join(out), headings


def _cells(row: str) -> list[str]:
    """Divide uma linha de tabela em células. Um | escapado (\\|) ou dentro de [[...]] não divide."""
    row = row.strip()
    if row.startswith("|"):
        row = row[1:]
    if row.endswith("|") and not row.endswith("\\|"):
        row = row[:-1]
    cells, current, depth, i = [], "", 0, 0
    while i < len(row):
        if row.startswith("[[", i):
            depth += 1
            current += "[["
            i += 2
            continue
        if row.startswith("]]", i) and depth:
            depth -= 1
            current += "]]"
            i += 2
            continue
        ch = row[i]
        if ch == "\\" and i + 1 < len(row) and row[i + 1] == "|":
            current += "|"
            i += 2
            continue
        if ch == "|" and depth == 0:
            cells.append(current.strip())
            current = ""
        else:
            current += ch
        i += 1
    cells.append(current.strip())
    return cells


def _align(cell: str) -> str:
    if cell.startswith(":") and cell.endswith(":"):
        return "center"
    if cell.endswith(":"):
        return "right"
    return ""


def _table(header: list[str], aligns: list[str], rows: list[list[str]], hook) -> str:
    def cell(tag: str, text: str, index: int) -> str:
        align = aligns[index] if index < len(aligns) else ""
        style = f' style="text-align:{align}"' if align else ""
        return f"<{tag}{style}>{inline(text, hook)}</{tag}>"

    head = "".join(cell("th", c, n) for n, c in enumerate(header))
    body = "".join(
        "<tr>" + "".join(cell("td", c, n) for n, c in enumerate(r)) + "</tr>" for r in rows
    )
    return f'<div class="tabela"><table><thead><tr>{head}</tr></thead><tbody>{body}</tbody></table></div>'


def _list(block: list[str], hook) -> str:
    """Listas com subníveis: a indentação de cada item define a profundidade."""
    items: list[tuple[int, bool, str]] = []
    for raw in block:
        match = _LIST_ITEM.match(raw)
        if match:
            depth = len(match.group(1).replace("\t", "    "))
            items.append((depth, match.group(2)[-1] == ".", match.group(3)))
        elif items:
            depth, ordered, text = items[-1]
            items[-1] = (depth, ordered, text + " " + raw.strip())

    html_parts: list[str] = []
    stack: list[tuple[int, str]] = []
    for depth, ordered, text in items:
        tag = "ol" if ordered else "ul"
        while stack and depth < stack[-1][0]:
            html_parts.append(f"</li></{stack.pop()[1]}>")
        if stack and depth == stack[-1][0] and tag != stack[-1][1]:
            # Mesmo nível, tipo diferente (marcador -> número): fecha uma lista e abre outra.
            html_parts.append(f"</li></{stack.pop()[1]}>")
        if not stack or depth > stack[-1][0]:
            html_parts.append(f"<{tag}>")
            stack.append((depth, tag))
        else:
            html_parts.append("</li>")
        html_parts.append("<li>" + inline(text, hook))
    while stack:
        html_parts.append(f"</li></{stack.pop()[1]}>")
    return "".join(html_parts)


def plain_text(markdown: str) -> str:
    """Texto sem formatação, para o índice de busca."""
    text = re.sub(r"```.*?```", " ", markdown, flags=re.S)
    text = re.sub(r"\[\[([^\]|]+)\|([^\]]+)\]\]", r"\2", text)
    text = re.sub(r"\[\[([^\]]+)\]\]", r"\1", text)
    text = _LINK.sub(r"\1", text)
    text = re.sub(r"\{\{[^}]+\}\}|\{[A-Z_]+\}", " ", text)
    text = re.sub(r"[#*`>|]", " ", text)
    return re.sub(r"\s+", " ", text).strip()
