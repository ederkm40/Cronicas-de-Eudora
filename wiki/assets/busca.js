/* Busca da Wiki: lê search-index.json (gerado junto com a Wiki) e filtra no próprio navegador.
   Sem bibliotecas externas. A função `buscar` também é testada no Node (tools/wiki/test_wiki.py). */
(function (raiz) {
  "use strict";

  function normalizar(texto) {
    return (texto || "").normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase();
  }

  /** Devolve os itens do índice que contêm todos os termos, os mais relevantes primeiro. */
  function buscar(indice, consulta) {
    var termos = normalizar(consulta).split(/\s+/).filter(function (t) { return t.length > 0; });
    if (termos.length === 0) return [];
    var resultados = [];
    indice.forEach(function (item) {
      var titulo = normalizar(item.t);
      var resumo = normalizar(item.r);
      var texto = normalizar(item.x);
      var pontos = 0;
      for (var i = 0; i < termos.length; i++) {
        var termo = termos[i];
        var noTitulo = titulo.indexOf(termo) !== -1;
        var noResumo = resumo.indexOf(termo) !== -1;
        var noTexto = texto.indexOf(termo) !== -1;
        if (!noTitulo && !noResumo && !noTexto) return;
        pontos += (noTitulo ? 10 : 0) + (noResumo ? 4 : 0) + (noTexto ? 1 : 0);
      }
      resultados.push({ item: item, pontos: pontos });
    });
    resultados.sort(function (a, b) { return b.pontos - a.pontos || a.item.t.localeCompare(b.item.t, "pt-BR"); });
    return resultados.map(function (r) { return r.item; });
  }

  function trecho(texto, consulta) {
    var termo = normalizar(consulta).split(/\s+/)[0] || "";
    var posicao = normalizar(texto).indexOf(termo);
    if (posicao < 0) return texto.slice(0, 160);
    var inicio = Math.max(0, posicao - 60);
    return (inicio > 0 ? "…" : "") + texto.slice(inicio, inicio + 180) + "…";
  }

  if (typeof module !== "undefined") {
    module.exports = { buscar: buscar, normalizar: normalizar };
    return;
  }

  var lista = document.getElementById("busca-resultados");
  var params = new URLSearchParams(window.location.search);
  var consulta = params.get("q") || "";
  var campo = document.querySelector(".busca input");
  if (campo && consulta) campo.value = consulta;
  if (!lista) return;

  var resumo = document.getElementById("busca-resumo");
  if (!consulta.trim()) return;
  fetch(raiz + "search-index.json")
    .then(function (r) { return r.json(); })
    .then(function (indice) {
      var achados = buscar(indice, consulta);
      resumo.textContent = achados.length === 0
        ? "Nada encontrado para “" + consulta + "”."
        : achados.length + (achados.length === 1 ? " resultado" : " resultados") + " para “" + consulta + "”.";
      resumo.classList.toggle("vazio", achados.length === 0);
      achados.forEach(function (item) {
        var li = document.createElement("li");
        var a = document.createElement("a");
        a.href = raiz + item.u;
        a.textContent = item.t;
        li.appendChild(a);
        if (item.c) {
          var cat = document.createElement("span");
          cat.className = "cat";
          cat.textContent = item.c;
          li.appendChild(cat);
        }
        var desc = document.createElement("span");
        desc.className = "resumo";
        desc.textContent = item.r || trecho(item.x, consulta);
        li.appendChild(desc);
        lista.appendChild(li);
      });
    })
    .catch(function () {
      resumo.textContent = "Não foi possível carregar o índice de busca.";
    });
})(typeof document !== "undefined" ? (document.body.getAttribute("data-raiz") || "") : "");
