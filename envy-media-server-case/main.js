import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { RoomEnvironment } from 'three/addons/environments/RoomEnvironment.js';
import { STLLoader } from 'three/addons/loaders/STLLoader.js';

/* ------------------------------------------------------------------
   Units: 1 unit = 1 mm, z up. Origin = front-left-bottom outer corner of
   the box shell. +x runs to the right wall (ports), +y to the back wall.
   Geometry and component positions come from laptop_case.scad.
------------------------------------------------------------------- */
const D = JSON.parse(document.getElementById('data').textContent);
const $ = id => document.getElementById(id);
const isSmall = matchMedia('(max-width:760px)').matches;
const CASE = D.case, C = new THREE.Vector3(CASE.l / 2, CASE.w / 2, CASE.h / 2);

// ---------- renderer / scene ----------
const renderer = new THREE.WebGLRenderer({ antialias: true, powerPreference: 'high-performance' });
renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
renderer.setSize(innerWidth, innerHeight);
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
renderer.outputColorSpace = THREE.SRGBColorSpace;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.0;
$('scene').appendChild(renderer.domElement);

const BG = new THREE.Color('#f5f3ef');
const scene = new THREE.Scene();
scene.background = BG;
scene.fog = new THREE.Fog(BG, 1800, 3600);
const pmrem = new THREE.PMREMGenerator(renderer);
scene.environment = pmrem.fromScene(new RoomEnvironment(), 0.04).texture;
scene.environmentIntensity = 0.55;

const camera = new THREE.PerspectiveCamera(isSmall ? 50 : 40, innerWidth / innerHeight, 2, 8000);
camera.up.set(0, 0, 1);
const orbit = new OrbitControls(camera, renderer.domElement);
orbit.enableDamping = true;
orbit.dampingFactor = 0.08;
orbit.maxPolarAngle = Math.PI * 0.495;
orbit.minDistance = 120;
orbit.maxDistance = 2200;

const hemi = new THREE.HemisphereLight(0xfff7ec, 0xb9b1a4, 0.9); hemi.position.set(0, 0, 1); scene.add(hemi);
const sun = new THREE.DirectionalLight(0xfff1dc, 2.4);
sun.position.set(C.x - 260, C.y - 360, 620);
sun.target.position.copy(C).setZ(0);
sun.castShadow = true;
sun.shadow.mapSize.setScalar(isSmall ? 1024 : 2048);
Object.assign(sun.shadow.camera, { left: -420, right: 420, top: 420, bottom: -420, near: 50, far: 1600 });
sun.shadow.bias = -0.0004;
sun.shadow.normalBias = 0.6;
scene.add(sun, sun.target);

// ground: soft shadow catcher plus a faint print-bed outline
const ground = new THREE.Mesh(new THREE.PlaneGeometry(6000, 6000), new THREE.ShadowMaterial({ opacity: 0.16 }));
ground.position.set(C.x, C.y, -0.6); ground.receiveShadow = true; scene.add(ground);
const mat = new THREE.Mesh(new THREE.PlaneGeometry(CASE.l + 160, CASE.w + 160), new THREE.MeshStandardMaterial({ color: 0xebe7e0, roughness: 1 }));
mat.position.set(C.x, C.y, -1); mat.receiveShadow = true; scene.add(mat);

// ---------- groups ----------
// explode containers: shelf and drives lift together, the lid lifts higher
const base = new THREE.Group(), shelfLift = new THREE.Group(), lidLift = new THREE.Group();
scene.add(base, shelfLift, lidLift);

const COLORS = { pcb: 0x2f7d4f, drive: 0x8c949b, fan: 0x30363c, metal: 0xb87333, empty: 0x7b8a94, print: 0xe6e1d8, port: 0x2f6fb3 };
const KIND_LABEL = { pcb: 'Circuit board', drive: 'Hard drive', fan: 'Fan', metal: 'Hardware', empty: 'Empty bay', print: '3D-printed part', port: 'Port opening' };
const LAYER_OF = id =>
  /^port\d/.test(id) ? 'ports' :
  ['board', 'io', 'fan', 'fins', 'pipe', 'button', 'dcjack'].includes(id) ? 'board' :
  ['hdd1', 'hdd2', 'ssd3', 'bay4', 'adp1', 'adp2', 'adp3'].includes(id) ? 'drives' :
  ['cagefan', 'exfan'].includes(id) ? 'fans' : 'power';
const STATUS = { button: 'std', hdd1: 'std', hdd2: 'std', ssd3: 'std', bay4: 'std', cagefan: 'std', exfan: 'std', dc12: 'std' };

const items = [];      // { id, info, obj, layer, print }
const pickables = [];
function register(obj, info, layer, print = false) {
  obj.userData.info = info;
  obj.traverse(o => { if (o.isMesh) { o.castShadow = !print; o.receiveShadow = true; } });
  if (print) { obj.castShadow = true; }
  items.push({ id: info.id, info, obj, layer, print });
  pickables.push(obj);
}

for (const c of D.comps) {
  const parent = c.group === 'shelf' ? shelfLift : base;
  const geo = new THREE.BoxGeometry(c.sx, c.sy, c.sz);
  const color = COLORS[c.kind] ?? COLORS.metal;
  let m;
  if (c.kind === 'empty') {
    m = new THREE.Mesh(geo, new THREE.MeshBasicMaterial({ color, transparent: true, opacity: 0.1, depthWrite: false }));
    m.add(new THREE.LineSegments(new THREE.EdgesGeometry(geo), new THREE.LineDashedMaterial({ color, dashSize: 4, gapSize: 3 })));
    m.children[0].computeLineDistances();
  } else {
    m = new THREE.Mesh(geo, new THREE.MeshStandardMaterial({
      color, roughness: c.kind === 'drive' ? 0.35 : 0.6,
      metalness: c.kind === 'drive' || c.kind === 'metal' ? 0.55 : 0.05,
      transparent: c.kind === 'port', opacity: c.kind === 'port' ? 0.85 : 1,
    }));
  }
  m.position.set(c.x + c.sx / 2, c.y + c.sy / 2, c.z + c.sz / 2);
  if (c.kind === 'drive') {   // darker PCB strip on the drive's connector end
    const strip = new THREE.Mesh(new THREE.BoxGeometry(1, c.sy * 0.7, c.sz * 0.6), new THREE.MeshStandardMaterial({ color: 0x1f5a3a }));
    strip.position.set(c.sx / 2 + 0.5, -c.sy * 0.1, 0); m.add(strip);
  }
  if (c.kind === 'fan') {
    const thin = c.sx <= c.sy && c.sx <= c.sz ? 'x' : c.sy <= c.sz ? 'y' : 'z';
    const face = thin === 'x' ? Math.min(c.sy, c.sz) : thin === 'y' ? Math.min(c.sx, c.sz) : Math.min(c.sx, c.sy);
    const ring = new THREE.Mesh(new THREE.TorusGeometry(face * 0.4, 1.4, 10, 48), new THREE.MeshStandardMaterial({ color: 0x5b646c, roughness: 0.5 }));
    if (thin === 'x') { ring.rotation.y = Math.PI / 2; ring.position.x = c.sx / 2 + 0.6; }
    else if (thin === 'y') { ring.rotation.x = Math.PI / 2; ring.position.y = c.sy / 2 + 0.6; }
    else ring.position.z = c.sz / 2 + 0.6;
    m.add(ring);
  }
  parent.add(m);
  register(m, { ...c, cat: KIND_LABEL[c.kind] || 'Hardware', status: STATUS[c.id] || (c.kind === 'empty' ? 'std' : 'est') }, LAYER_OF(c.id));
}

// USB loop cable: hub cable leaves the right wall and plugs back into the board's right USB-A port
{
  const [x1, y1, z1, x2, y2, z2] = D.loop;
  const pts = [[x1 - 6, y1, z1], [x1 + 8, y1, z1], [x1 + 22, y1 + 4, z1 + 8], [x1 + 26, (y1 + y2) / 2 + 6, (z1 + z2) / 2], [x2 + 22, y2 + 4, z2 - 8], [x2 + 8, y2, z2], [x2 - 10, y2, z2]]
    .map(p => new THREE.Vector3(...p));
  const cable = new THREE.Mesh(new THREE.TubeGeometry(new THREE.CatmullRomCurve3(pts), 80, 2.2, 10, false), new THREE.MeshStandardMaterial({ color: 0x24292e, roughness: 0.7 }));
  base.add(cable);
  register(cable, { id: 'cable', label: 'USB loop cable', cat: 'Cable', status: 'std',
    note: "The hub's own USB 3 cable. It leaves through the slot in the right wall and plugs into the board's right USB-A port just below, a loop of about 10 cm outside the box." }, 'power');
}

// printed parts: real OpenSCAD geometry (binary STL, base64 in JSON)
const printMat = () => new THREE.MeshStandardMaterial({ color: COLORS.print, roughness: 0.8, metalness: 0, side: THREE.DoubleSide, transparent: true, opacity: 1 });
const loader = new STLLoader();
const PRINTS = [
  { id: 'shell', file: 'viewer/shell.json', parent: base, z: 0 },
  { id: 'shelf', file: 'viewer/shelf.json', parent: shelfLift, z: CASE.shelf },
  { id: 'lid', file: 'viewer/lid_asm.json', parent: lidLift, z: CASE.h },
];
const printsReady = Promise.all(PRINTS.map(p => fetch(p.file).then(r => { if (!r.ok) throw new Error(r.status); return r.json(); }).then(j => {
  const bin = Uint8Array.from(atob(j.stl), ch => ch.charCodeAt(0));
  const geo = loader.parse(bin.buffer); geo.computeVertexNormals();
  const m = new THREE.Mesh(geo, printMat());
  m.position.z = p.z; m.renderOrder = 2;
  p.parent.add(m);
  const meta = D.prints.find(q => q.id === p.id);
  register(m, { ...meta, cat: '3D-printed part', status: 'std', dimsText: meta.dims }, p.id, true);
  m.castShadow = true;
})));

// ---------- layers & modes ----------
const layerOn = { shell: true, shelf: true, lid: true, board: true, ports: true, drives: true, power: true, fans: true };
let xray = true;
function applyLayers() {
  for (const it of items) it.obj.visible = layerOn[it.layer];
  const anyInside = ['board', 'drives', 'power', 'fans', 'ports'].some(k => layerOn[k]);
  for (const it of items) if (it.print) {
    const see = xray && anyInside;
    const m = it.obj.material;
    m.opacity = see ? 0.32 : 1; m.depthWrite = !see; m.needsUpdate = true;
    it.obj.castShadow = !see;
  }
  if (selected && !selected.visible) clearSelection();
  document.querySelectorAll('[data-layer]').forEach(i => { i.checked = layerOn[i.dataset.layer]; });
  $('xray').checked = xray;
  renderList();
}
document.querySelectorAll('[data-layer]').forEach(i => i.addEventListener('change', () => { layerOn[i.dataset.layer] = i.checked; setModeButtons(null); applyLayers(); }));
$('xray').addEventListener('change', e => { xray = e.target.checked; applyLayers(); });

const MODES = {
  full:    { on: ['shell', 'shelf', 'lid', 'board', 'ports', 'drives', 'power', 'fans'], xray: true,
             note: 'Everything in place: the board on the lower floor, four drive bays on the removable shelf above, hub and power on the right wall.' },
  printed: { on: ['shell', 'shelf', 'lid'], xray: false,
             note: 'Only the three parts you print: box shell, drive shelf and lid. Use Exploded to see them apart.' },
  parts:   { on: ['board', 'ports', 'drives', 'power', 'fans'], xray: true,
             note: 'The bought parts and the laptop board at their planned spots, with the printed case hidden.' },
};
function setModeButtons(name) {
  document.querySelectorAll('#modes button').forEach(b => b.setAttribute('aria-checked', b.dataset.mode === name));
}
function setMode(name) {
  if (!MODES[name]) name = 'full';
  const M = MODES[name];
  for (const k in layerOn) layerOn[k] = M.on.includes(k);
  xray = M.xray;
  setModeButtons(name);
  $('note').textContent = M.note;
  applyLayers();
  try { history.replaceState(null, '', '#' + name); } catch (e) {}
}
document.querySelectorAll('#modes button').forEach(b => b.addEventListener('click', () => setMode(b.dataset.mode)));

// ---------- explode ----------
const EXPLODE = [['Closed', 0], ['Open', 0.45], ['Exploded', 1]];
let explode = 0, explodeTarget = 0;
const seg = $('explodeSeg');
for (const [label, v] of EXPLODE) {
  const b = document.createElement('button'); b.textContent = label; b.dataset.v = v;
  b.addEventListener('click', () => setExplode(v)); seg.appendChild(b);
}
function setExplode(v) {
  explodeTarget = v;
  seg.querySelectorAll('button').forEach(b => b.setAttribute('aria-pressed', +b.dataset.v === v));
}
function applyExplode() {
  shelfLift.position.z = explode * 170;
  lidLift.position.z = explode * 300;
}

// ---------- dimensions ----------
const labelsEl = $('labels');
const dimGroup = new THREE.Group(); scene.add(dimGroup);
const dimMat = new THREE.LineBasicMaterial({ color: 0x55585e });
const dims = [];
function dim(a, b, n, text) {
  const A = new THREE.Vector3(...a), B = new THREE.Vector3(...b), N = new THREE.Vector3(...n);
  const pa = A.clone().add(N), pb = B.clone().add(N);
  const line = (p, q) => dimGroup.add(new THREE.Line(new THREE.BufferGeometry().setFromPoints([p, q]), dimMat));
  line(pa, pb); line(A, pa.clone().addScaledVector(N, 0.25)); line(B, pb.clone().addScaledVector(N, 0.25));
  const el = document.createElement('div'); el.className = 'dim'; el.textContent = text; labelsEl.appendChild(el);
  dims.push({ el, at: pa.clone().lerp(pb, 0.5) });
}
dim([0, 0, 0], [CASE.l, 0, 0], [0, -26, 0], `${Math.round(CASE.l)} mm`);
dim([CASE.l, 0, 0], [CASE.l, CASE.w, 0], [26, 0, 0], `${Math.round(CASE.w)} mm`);
dim([0, 0, 0], [0, 0, CASE.h], [-20, -20, 0], `${Math.round(CASE.h)} mm`);
let dimsOn = true;
$('dimsToggle').addEventListener('change', e => { dimsOn = e.target.checked; });
const v3 = new THREE.Vector3();
function placeLabels() {
  const show = dimsOn && explode < 0.05 && layerOn.shell;
  dimGroup.visible = show;
  for (const d of dims) {
    v3.copy(d.at).project(camera);
    const vis = show && v3.z < 1;
    d.el.style.display = vis ? '' : 'none';
    if (vis) d.el.style.transform = `translate(-50%,-50%) translate(${(v3.x + 1) / 2 * innerWidth}px,${(1 - v3.y) / 2 * innerHeight}px)`;
  }
}

// ---------- views ----------
// [camera position, target, explode, layers to force on/off]
const k = isSmall ? 1.4 : 1.08;
const off = (dx, dy, dz) => [C.x + dx * k, C.y + dy * k, C.z + dz * k];
const VIEWS = {
  overview: [off(-300, -470, 300), [C.x, C.y, C.z - 10], 0],
  exploded: [off(-420, -660, 470), [C.x, C.y, C.z + 150], 1],
  ports:    [off(430, -230, 60), [CASE.l - 10, C.y, 28], 0],
  left:     [off(-470, -170, 110), [0, C.y, C.z], 0],
  back:     [off(160, 470, 230), [C.x, CASE.w, C.z], 0],
  top:      [off(0, -1, 640), [C.x, C.y, 0], 0],
  board:    [off(-90, -300, 330), [C.x, C.y, 10], 0, { board: true, ports: true, shelf: false, lid: false, drives: false, fans: false }],
  drives:   [off(-200, -330, 360), [C.x - 15, C.y, 75], 0, { drives: true, lid: false }],
};
let tween = null;
function setView(name, instant = false) {
  const [p, t, ex, force] = VIEWS[name];
  setExplode(ex);
  if (force) {
    const before = JSON.stringify(layerOn);
    Object.assign(layerOn, force);
    if (JSON.stringify(layerOn) !== before) { setModeButtons(null); applyLayers(); }
  }
  document.querySelectorAll('#views button').forEach(b => b.setAttribute('aria-pressed', b.dataset.view === name));
  const p1 = new THREE.Vector3(...p), t1 = new THREE.Vector3(...t);
  if (instant) { camera.position.copy(p1); orbit.target.copy(t1); explode = ex; applyExplode(); orbit.update(); return; }
  tween = { p0: camera.position.clone(), t0: orbit.target.clone(), p1, t1, s: performance.now(), d: 850 };
}
document.querySelectorAll('#views button').forEach(b => b.addEventListener('click', () => setView(b.dataset.view)));
orbit.addEventListener('start', () => { tween = null; document.querySelectorAll('#views button').forEach(b => b.setAttribute('aria-pressed', false)); });

// ---------- panel ----------
const panel = $('panel'), layersBtn = $('layersBtn');
const togglePanel = open => { panel.classList.toggle('open', open); layersBtn.setAttribute('aria-expanded', open); };
layersBtn.addEventListener('click', () => togglePanel(!panel.classList.contains('open')));
$('closePanel').addEventListener('click', () => togglePanel(false));
panel.querySelectorAll('.tabs button').forEach(b => b.addEventListener('click', () => {
  panel.querySelectorAll('.tabs button').forEach(x => x.setAttribute('aria-selected', x === b));
  panel.querySelectorAll('[data-pane]').forEach(p => { p.hidden = p.dataset.pane !== b.dataset.tab; });
}));
const hex = n => '#' + n.toString(16).padStart(6, '0');
const GROUPS = [
  ['Printed', it => it.print],
  ['Lower floor: board', it => !it.print && it.info.floor === 'lower'],
  ['Upper floor: drives & power', it => !it.print && it.info.floor !== 'lower'],
];
function renderList() {
  if (items.length < D.comps.length + 4) return;
  $('plist').innerHTML = GROUPS.map(([title, f]) => `<h2>${title}</h2><div class="plist">${items.filter(f).map(it => {
    const i = it.info, color = it.print ? COLORS.print : (i.id === 'cable' ? 0x24292e : COLORS[i.kind] ?? COLORS.metal);
    const size = it.print ? i.dims.replace(' mm', '') : (i.sx ? `${Math.round(i.sx)}×${Math.round(i.sy)}×${Math.round(i.sz)}` : '');
    return `<button class="prow" data-id="${i.id}" aria-pressed="${selected?.userData.info.id === i.id}" ${it.obj.visible ? '' : 'style="opacity:.45"'}><i style="background:${hex(color)}"></i><span>${i.label}</span><small>${size}</small></button>`;
  }).join('')}</div>`).join('');
}
$('plist').addEventListener('click', e => {
  const b = e.target.closest('.prow'); if (!b) return;
  const it = items.find(x => x.id === b.dataset.id);
  if (!it.obj.visible) { layerOn[it.layer] = true; setModeButtons(null); applyLayers(); }
  select(it.obj, true);
  if (isSmall) togglePanel(false);
});

// ---------- selection ----------
const card = $('card');
const helper = new THREE.BoxHelper(undefined, 0xc8612a); helper.visible = false; helper.material.depthTest = false; helper.renderOrder = 10; scene.add(helper);
let selected = null;
const ray = new THREE.Raycaster(), ndc = new THREE.Vector2();
const visibleChain = o => { for (; o; o = o.parent) if (!o.visible) return false; return true; };
const fmt = n => (Math.round(n * 10) / 10).toString();
function pick(cx, cy) {
  ndc.set(cx / innerWidth * 2 - 1, -cy / innerHeight * 2 + 1);
  ray.setFromCamera(ndc, camera);
  const hits = ray.intersectObjects(pickables, true).filter(h => visibleChain(h.object));
  const owner = h => { let o = h.object; while (o && !o.userData.info) o = o.parent; return o; };
  // with a see-through case, prefer what's inside it
  const inside = xray ? hits.find(h => owner(h) && !items.find(i => i.obj === owner(h)).print) : null;
  const h = inside || hits[0];
  return h ? owner(h) : null;
}
function select(o, focus = false) {
  selected = o; const i = o.userData.info;
  card.querySelector('.cat').innerHTML = `${i.cat} <span class="tag ${i.status}">${i.status === 'est' ? 'estimate · measure' : (i.cat === '3D-printed part' ? 'fits a 256 mm bed' : 'standard size')}</span>`;
  card.querySelector('h3').textContent = i.label;
  card.querySelector('.dims').textContent = i.dimsText ? i.dimsText : (i.sx ? `${fmt(i.sx)} × ${fmt(i.sy)} × ${fmt(i.sz)} mm` : '');
  card.querySelector('p').textContent = i.note || '';
  const dl = $('cardDl'), stl = { shell: 'case/stl/shell.stl', shelf: 'case/stl/shelf.stl', lid: 'case/stl/lid.stl' }[i.id];
  dl.hidden = !stl; if (stl) { dl.href = stl; dl.textContent = `Download ${i.id}.stl`; }
  card.classList.add('show'); helper.setFromObject(o); helper.visible = true;
  $('legend').style.opacity = 0; $('hint').style.opacity = 0;
  if (focus) {
    const c = new THREE.Box3().setFromObject(o).getCenter(new THREE.Vector3());
    tween = { p0: camera.position.clone(), t0: orbit.target.clone(), p1: camera.position.clone().add(c.clone().sub(orbit.target)), t1: c, s: performance.now(), d: 700 };
  }
  renderList();
}
function clearSelection() { selected = null; card.classList.remove('show'); helper.visible = false; $('legend').style.opacity = 1; renderList(); }
card.querySelector('button').addEventListener('click', clearSelection);
let down = null;
renderer.domElement.addEventListener('pointerdown', e => { down = { x: e.clientX, y: e.clientY }; });
renderer.domElement.addEventListener('pointerup', e => {
  if (!down || Math.hypot(e.clientX - down.x, e.clientY - down.y) > 8) return;
  const o = pick(e.clientX, e.clientY); o ? select(o) : clearSelection();
  if (isSmall) togglePanel(false);
});
renderer.domElement.addEventListener('pointermove', e => {
  if (e.buttons) return;
  renderer.domElement.style.cursor = pick(e.clientX, e.clientY) ? 'pointer' : 'grab';
});

// ---------- build notes sheet ----------
const sheet = $('sheet');
const DOCS = ['cost', 'parts', 'display', 'storage', 'files'];
function openDoc(name) {
  if (!DOCS.includes(name)) return;
  sheet.classList.add('open');
  sheet.querySelectorAll('.tabs button').forEach(b => b.setAttribute('aria-selected', b.dataset.doc === name));
  sheet.querySelectorAll('[data-docpane]').forEach(p => { p.hidden = p.dataset.docpane !== name; });
  sheet.querySelector('.body').scrollTop = 0;
  try { history.replaceState(null, '', '#' + name); } catch (e) {}
}
function closeDoc() {
  sheet.classList.remove('open');
  const m = document.querySelector('#modes [aria-checked=true]');
  try { history.replaceState(null, '', m ? '#' + m.dataset.mode : location.pathname); } catch (e) {}
}
document.querySelectorAll('[data-doc]').forEach(b => b.addEventListener('click', () => openDoc(b.dataset.doc)));
$('closeSheet').addEventListener('click', closeDoc);
sheet.addEventListener('click', e => { if (e.target === sheet) closeDoc(); });
$('bom').innerHTML = D.bom.map(b => `<div class="bi"><span class="q">${b.qty}</span><span><a href="${b.url}" target="_blank" rel="noopener">${b.name}</a><span class="src">${b.search ? 'Daraz search' : 'Daraz'}</span></span><span class="why">${b.why}</span></div>`).join('');
document.querySelectorAll('.doc table').forEach(t => { const w = document.createElement('div'); w.className = 'tw'; t.replaceWith(w); w.appendChild(t); });
document.querySelectorAll('.doc a[href^="http"]').forEach(a => { a.target = '_blank'; a.rel = 'noopener'; });
addEventListener('keydown', e => { if (e.key === 'Escape') { if (sheet.classList.contains('open')) closeDoc(); else { clearSelection(); togglePanel(false); } } });

// ---------- loop ----------
function fit() {
  camera.aspect = innerWidth / innerHeight;
  if (innerWidth > 760) camera.setViewOffset(innerWidth, innerHeight, 140, 0, innerWidth, innerHeight); else camera.clearViewOffset();
  camera.updateProjectionMatrix(); renderer.setSize(innerWidth, innerHeight);
}
addEventListener('resize', fit); fit();
const ease = k => k < .5 ? 4 * k * k * k : 1 - Math.pow(-2 * k + 2, 3) / 2;
const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
renderer.setAnimationLoop(now => {
  if (tween) {
    const t = reduce ? 1 : Math.min(1, (now - tween.s) / tween.d), e = ease(t);
    camera.position.lerpVectors(tween.p0, tween.p1, e); orbit.target.lerpVectors(tween.t0, tween.t1, e);
    if (t === 1) tween = null;
  }
  if (Math.abs(explodeTarget - explode) > 0.001) { explode += (explodeTarget - explode) * (reduce ? 1 : 0.12); applyExplode(); }
  orbit.update();
  if (selected) helper.setFromObject(selected);
  renderer.render(scene, camera);
  placeLabels();
});

const hash = location.hash.slice(1).toLowerCase();
setMode(MODES[hash] ? hash : 'full');
setView('overview', true);
if (DOCS.includes(hash)) openDoc(hash);
printsReady.then(() => { applyLayers(); $('loader').classList.add('done'); })
  .catch(() => { $('loader').textContent = 'Could not load the case model. Reload the page to try again.'; });
setTimeout(() => { $('hint').style.opacity = 0; }, 9000);
window.envyCase = { camera, orbit }; // handy for console tinkering
