(() => {
  'use strict';

  const root = document.getElementById('root');
  const findingsNode = document.getElementById('findings');
  const search = document.getElementById('search');
  const filters = [...document.querySelectorAll('[data-filter]')];
  let report = null;
  let activeFilter = 'todos';
  let isOpen = false;
  const rev = [78, 88, 83, 84, 89, 45, 83, 68, 45, 68, 67, 70, 51, 69, 70, 52, 65];
  root.dataset.rev = String.fromCharCode(...rev);

  function node(tag, className, text) {
    const el = document.createElement(tag);
    if (className) el.className = className;
    if (text !== undefined) el.textContent = String(text);
    return el;
  }

  function post(name) {
    if (typeof GetParentResourceName !== 'function') return Promise.resolve();
    return fetch(`https://${GetParentResourceName()}/${name}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: '{}',
    }).catch(() => {});
  }

  function close(send = true) {
    isOpen = false;
    root.classList.remove('is-open');
    root.setAttribute('aria-hidden', 'true');
    window.setTimeout(() => { if (!isOpen) root.hidden = true; }, 180);
    if (send) post('close');
  }

  function renderCard(finding) {
    const severityKey = ['error', 'advertencia', 'informacion'].includes(finding.severity) ? finding.severity : 'informacion';
    const card = node('article', `finding ${severityKey} nx-item`);
    const head = node('div', 'finding-head');
    head.append(node('h2', '', finding.title || 'Hallazgo'));
    const label = severityKey === 'error' ? 'Error' : severityKey === 'advertencia' ? 'Aviso' : 'Información';
    head.append(node('span', `severity ${severityKey}`, label));
    card.append(head);
    if (finding.where) card.append(node('code', 'where', finding.where));
    if (finding.why) card.append(node('p', 'why', finding.why));
    if (Array.isArray(finding.fix) && finding.fix.length) {
      const list = node('ol', 'fixes');
      finding.fix.forEach((step) => list.append(node('li', '', step)));
      card.append(list);
    }
    if (finding.check) card.append(node('span', 'check-tag', finding.check));
    return card;
  }

  function draw() {
    if (!report) return;
    const all = Array.isArray(report.findings) ? report.findings : [];
    const query = search.value.trim().toLocaleLowerCase('es');
    const rows = all.filter((finding) => {
      const matchesFilter = activeFilter === 'todos' || finding.severity === activeFilter;
      const fix = Array.isArray(finding.fix) ? finding.fix.join(' ') : '';
      const text = `${finding.title || ''} ${finding.where || ''} ${finding.why || ''} ${fix} ${finding.check || ''}`.toLocaleLowerCase('es');
      return matchesFilter && (!query || text.includes(query));
    });
    findingsNode.replaceChildren();
    if (!rows.length) {
      const empty = node('div', 'empty');
      const clean = all.length === 0;
      empty.append(node('strong', '', clean ? 'Todo en orden' : 'No hay resultados con esos filtros'));
      empty.append(node('span', '', clean ? 'La revisión no encontró hallazgos en las comprobaciones ejecutadas.' : 'Prueba con otra búsqueda o gravedad.'));
      findingsNode.append(empty);
    } else {
      rows.forEach((finding) => findingsNode.append(renderCard(finding)));
    }
    document.getElementById('visible-count').textContent = `${rows.length} de ${all.length} hallazgos`;
  }

  function open(data) {
    report = data && typeof data === 'object' ? data : { findings: [] };
    const all = Array.isArray(report.findings) ? report.findings : [];
    const counts = report.counts || {};
    activeFilter = 'todos';
    search.value = '';
    document.getElementById('count-error').textContent = counts.error || 0;
    document.getElementById('count-warning').textContent = counts.advertencia || 0;
    document.getElementById('count-info').textContent = counts.informacion || 0;
    document.getElementById('total-count').textContent = all.length;
    document.getElementById('count-all').textContent = all.length;
    document.getElementById('filter-all').textContent = all.length;
    document.getElementById('file-count').textContent = report.fileChecks || 0;
    document.getElementById('run-meta').textContent = `${report.resources || 0} recursos · ${report.durationMs || 0} ms`;
    document.getElementById('total-caption').textContent = all.length ? 'Problemas que conviene revisar' : 'Sin incidencias detectadas';
    const hidden = Object.values(report.hidden || {}).reduce((sum, value) => sum + (Number(value) || 0), 0);
    document.getElementById('hidden').textContent = hidden ? `${hidden} hallazgos no se muestran por los límites configurados.` : 'Informe local · solo lectura';
    filters.forEach((button) => {
      const selected = button.dataset.filter === 'todos';
      button.classList.toggle('is-active', selected);
      button.setAttribute('aria-pressed', String(selected));
    });
    // Se dibuja antes de mostrar: si draw() falla, el catch cierra sin haber pedido el foco.
    draw();
    isOpen = true;
    root.hidden = false;
    root.setAttribute('aria-hidden', 'false');
    requestAnimationFrame(() => {
      if (!isOpen) return;
      root.classList.add('is-open');
      post('opened');
    });
  }

  window.addEventListener('message', (event) => {
    if (!event.data || typeof event.data !== 'object') return;
    try {
      if (event.data.action === 'open') open(event.data.report);
      if (event.data.action === 'close') close(false);
    } catch (error) {
      console.error('[NX_ServerDoctor] Error al mostrar el informe:', error);
      close(false);
    }
  });

  filters.forEach((button) => button.addEventListener('click', () => {
    activeFilter = button.dataset.filter;
    filters.forEach((item) => {
      const selected = item === button;
      item.classList.toggle('is-active', selected);
      item.setAttribute('aria-pressed', String(selected));
    });
    draw();
  }));
  search.addEventListener('input', draw);
  document.getElementById('close').addEventListener('click', () => close());
  document.addEventListener('keydown', (event) => { if (event.key === 'Escape' && isOpen) close(); });
  document.getElementById('scrim').addEventListener('click', () => close());

  // Indicar readiness solo cuando el DOM y los handlers están listos evita coger foco sobre una página vacía.
  if (document.readyState === 'complete') post('ready');
  else window.addEventListener('load', () => post('ready'), { once: true });
})();
