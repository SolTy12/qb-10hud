const hud = document.getElementById('hud');
const settings = document.getElementById('settings');
const list = document.getElementById('list');
const counter = document.getElementById('counter');

let copsCache = {};
let dragging = false;
let offsetX = 0;
let offsetY = 0;
let settingsOpen = false;
let hudScale = parseFloat(localStorage.getItem('hudScale')) || 1;
hud.style.transform = `scale(${hudScale})`;
hud.style.transformOrigin = 'top right';


// מצב קיפול מחלקות
let collapsedDepartments = JSON.parse(localStorage.getItem('collapsedDepartments')) || {};

/* =========================
   LOAD SAVED POSITION
========================= */
const savedPos = JSON.parse(localStorage.getItem('hudPos'));
if (savedPos) {
    hud.style.left = savedPos.x + 'px';
    hud.style.top = savedPos.y + 'px';
    hud.style.right = 'auto';
}

/* =========================
   NUI MESSAGE HANDLER
========================= */
window.addEventListener('message', (e) => {
    const d = e.data || {};

    switch (d.action) {
        case 'openSettings':
            settings.style.display = 'block';
            settingsOpen = true;
            break;

        case 'closeSettings':
            settings.style.display = 'none';
            settingsOpen = false;
            saveHudPos();
            break;

        case 'toggleHud':
            hud.style.display = d.state ? 'block' : 'none';
            break;

        case 'update':
            copsCache = d.list || {};
            renderList(copsCache);
            break;

        case 'setSavedTag':
            const tagInput = document.getElementById('tag');
            const colorInput = document.getElementById('color');
            if (tagInput && d.tag) tagInput.value = d.tag;
            if (colorInput && d.color) colorInput.value = d.color;
            break;
    }
});

/* =========================
   DRAG & SAVE
========================= */
hud.addEventListener('mousedown', (e) => {
    if (!settingsOpen) return;
    dragging = true;
    offsetX = e.clientX - hud.offsetLeft;
    offsetY = e.clientY - hud.offsetTop;
    hud.style.cursor = 'move';
});

document.addEventListener('mousemove', (e) => {
    if (!dragging) return;
    hud.style.left = (e.clientX - offsetX) + 'px';
    hud.style.top = (e.clientY - offsetY) + 'px';
    hud.style.right = 'auto';
});

document.addEventListener('mouseup', () => {
    if (!dragging) return;
    dragging = false;
    hud.style.cursor = 'default';
    saveHudPos();
});

function saveHudPos() {
    localStorage.setItem('hudPos', JSON.stringify({
        x: hud.offsetLeft,
        y: hud.offsetTop
    }));
}

/* =========================
   RENDER LIST (FINAL & SAFE)
========================= */
function renderList(cops) {
    list.innerHTML = '';

    let validCopsCount = 0;
    const departments = {};

    Object.keys(cops || {}).forEach(id => {
        const c = cops[id];
        if (!c || !c.name) return;

        validCopsCount++;

        const dept = c.department || 'משטרה';
        if (!departments[dept]) departments[dept] = [];

        departments[dept].push({
            id,
            tag: c.tag,
            name: c.name,
            color: c.color || '#666',
            headshot: c.headshot || '',
            radio: c.radio || '-',
            talking: !!c.talking
        });
    });

    counter.innerText = `${validCopsCount} שוטרים מחוברים`;

    if (validCopsCount === 0) return;

    Object.keys(departments).forEach(deptName => {
        const deptCops = departments[deptName];

        // מיון לפי תג (נמוך למעלה)
        deptCops.sort((a, b) => {
            const ta = parseInt(a.tag) || 9999;
            const tb = parseInt(b.tag) || 9999;
            return ta - tb;
        });

        const title = document.createElement('div');
        title.className = 'department-title';
        title.innerHTML = `
            <span>${getDepartmentLabel(deptName)}</span>
            <span>${collapsedDepartments[deptName] ? '▸' : '▾'}</span>
        `;
        title.onclick = () => toggleDepartment(deptName);
        list.appendChild(title);

        if (collapsedDepartments[deptName]) return;

        deptCops.forEach(c => {
            const row = document.createElement('div');
            row.className = 'row';
            row.dataset.id = c.id;

            // Debug logging
            console.log('[qb-10hud] Officer data:', {
                name: c.name,
                headshot: c.headshot ? c.headshot.substring(0, 50) + '...' : 'null',
                isBase64: c.headshot && c.headshot.startsWith('data:')
            });

            row.innerHTML = `
                <div class="row-left">
                    <img class="avatar" src="${c.headshot && c.headshot.startsWith('data:') ? c.headshot : (c.headshot ? 'https://nui-img/' + c.headshot + '/' + c.headshot : 'html/logo.png')}" onerror="this.src='html/logo.png'">
                    <span class="tag" style="background:${c.color}">${c.tag}</span>
                    <span class="name">${c.name}</span>
                </div>
                <div class="row-right">
                    ${c.talking ? '<span class="mic">🎤</span>' : ''}
                    <span class="radio ${c.talking ? 'radio-talking' : ''}">
                        ${c.radio} Hz
                    </span>
                </div>
            `;
            list.appendChild(row);
        });
    });
}

/* =========================
   HELPERS
========================= */
function toggleDepartment(name) {
    collapsedDepartments[name] = !collapsedDepartments[name];
    localStorage.setItem('collapsedDepartments', JSON.stringify(collapsedDepartments));
    renderList(copsCache);
}

function getDepartmentLabel(name) {
    const map = {
        'סיור שוטרים': 'סיור שוטרים 👮‍♂️',
        'אקדמאים': 'אקדמאים 🎓',
        'יס״מ': 'יס״מ 🛡️',
        'ימ״מ': 'ימ״מ ⚔️',
        'פיקוד': 'פיקוד ⭐',
        'משטרה': 'משטרה 🚓'
    };
    return map[name] || name;
}

/* =========================
   ESC CLOSE SETTINGS
========================= */
window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && settingsOpen) {
        fetch(`https://${GetParentResourceName()}/close`, { method: 'POST' });
    }
});

/* =========================
   SETTINGS CALLBACKS
========================= */
function onList() {
    fetch(`https://${GetParentResourceName()}/onList`, {
        method: 'POST',
        body: JSON.stringify({
            tag: document.getElementById('tag').value,
            color: document.getElementById('color').value
        })
    });
}

function offList() {
    fetch(`https://${GetParentResourceName()}/offList`, { method: 'POST' });
}

const scaleInput = document.getElementById('hudScale');

if (scaleInput) {
    scaleInput.value = hudScale;

    scaleInput.addEventListener('input', (e) => {
        hudScale = parseFloat(e.target.value);
        hud.style.transform = `scale(${hudScale})`;
        localStorage.setItem('hudScale', hudScale);
    });
}
