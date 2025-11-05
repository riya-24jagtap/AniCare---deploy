// ----------------------
// Section switching
// ----------------------
function showSection(id) {
    ['dashboard', 'cases'].forEach(s => {
        document.getElementById(s).style.display = (s === id) ? 'block' : 'none';
    });

    // Highlight active tab
    document.querySelectorAll('.tab-nav button').forEach(btn => {
        btn.classList.toggle('active', btn.dataset.tab === id);
    });

    // Save active tab
    localStorage.setItem('activeNGOTab', id);

    // Render the section
    if (id === 'dashboard') renderDashboard();
    if (id === 'cases') renderCases();
}

// ----------------------
// Render Dashboard
// ----------------------
function renderDashboard() {
    const pending = casesData.filter(c => c.status.toLowerCase() === 'pending').length;
    const inProgress = casesData.filter(c => c.status.toLowerCase() === 'in progress').length;
    const resolved = casesData.filter(c => c.status.toLowerCase() === 'resolved').length;

    document.getElementById('casesPending').textContent = pending;
    document.getElementById('casesInProgress').textContent = inProgress;
    document.getElementById('casesResolved').textContent = resolved;

    // Alerts
    const alertsList = document.getElementById('alertsList');
    const alerts = casesData
        .filter(c => c.status.toLowerCase() === 'pending')
        .map(c => `<li>New case: ${c.animal} (ID:${c.id}) at ${c.reportedAt}</li>`);
    alertsList.innerHTML = alerts.length ? alerts.join('') : '<li>No new alerts</li>';
}

// ----------------------
// Render Cases Table
// ----------------------
function renderCases() {
    const tbody = document.getElementById('casesTableBody');
    const resolvedTbody = document.getElementById('resolvedCasesTableBody');

    tbody.innerHTML = '';
    resolvedTbody.innerHTML = '';

    casesData.forEach(c => {
        const row = document.createElement('tr');
        const statusNormalized = c.status.toLowerCase();

        row.className = getStatusClass(c.status);

        // Photo cell using the correct key 'photo_url'
        const photoCell = c.photo_url
            ? `<img src="${c.photo_url}" alt="${c.animal}" class="case-photo" onclick="openModal('${c.photo_url}', '${c.animal}')">`
            : `<span class="no-photo">No photo</span>`;

        // Build row HTML
        let rowHTML = `
            <td>${c.id}</td>
            <td>${c.animal}</td>
            <td>${c.desc}</td>
            <td>${photoCell}</td> <!-- Always include photo -->
            <td>${c.reporter}</td>
            <td>${c.reportedAt}</td>
            <td>
                <select id="caseStatusSelect-${c.id}">
                    <option ${statusNormalized === 'pending' ? 'selected' : ''}>Pending</option>
                    <option ${statusNormalized === 'in progress' ? 'selected' : ''}>In Progress</option>
                    <option ${statusNormalized === 'resolved' ? 'selected' : ''}>Resolved</option>
                </select>
            </td>
            <td>
                <button class="mark-action-btn" onclick="markAction(${c.id})">Mark Action</button>
            </td>
        `;

        row.innerHTML = rowHTML;

        // Apply color to dropdown
        const selectEl = row.querySelector(`#caseStatusSelect-${c.id}`);
        selectEl.className = statusNormalized.replace(' ', '-');

        // Append to the correct table
        if (statusNormalized === 'resolved') resolvedTbody.appendChild(row);
        else tbody.appendChild(row);
    });
}

// ----------------------
// Open photo modal
// ----------------------
function openModal(src, alt) {
    const modal = document.getElementById('photoModal');
    const modalImg = document.getElementById('modalImg');
    const caption = document.getElementById('caption');

    modal.style.display = "block";
    modalImg.src = src;
    caption.textContent = alt;
}

// Close modal when clicking X
document.querySelector('.modal-close').onclick = function() {
    document.getElementById('photoModal').style.display = "none";
}

// Close modal when clicking outside the image
document.getElementById('photoModal').onclick = function(e) {
    if (e.target.id === 'photoModal') this.style.display = "none";
}


// ----------------------
// Update Case Status
// ----------------------
function markAction(caseId) {
    const selectEl = document.querySelector(`#caseStatusSelect-${caseId}`);
    const newStatus = selectEl.value;

    fetch('/update_case_status', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: caseId, status: newStatus })
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            const c = casesData.find(c => c.id === caseId);
            if (c) c.status = newStatus;
            renderCases();
            renderDashboard();
        } else {
            alert("Failed to update status. Try again.");
        }
    })
    .catch(err => {
        console.error("Error updating case status:", err);
        alert("Error updating status");
    });
}

// ----------------------
// Helper Functions
// ----------------------
function getStatusClass(status) {
    const s = status.toLowerCase();
    return s === 'pending' ? 'pending' : s === 'in progress' ? 'in-progress' : s === 'resolved' ? 'resolved' : '';
}

// ----------------------
// Auto-refresh NGO cases every 15 seconds
// ----------------------
let autoRefresh = true;
let casesData = [];

setInterval(() => {
    if (!autoRefresh) return;
    fetch('/ngo_dashboard_json')
        .then(res => res.json())
        .then(data => {
            casesData = data;
            const activeTab = localStorage.getItem('activeNGOTab') || 'dashboard';
            if (activeTab === 'dashboard') renderDashboard();
            if (activeTab === 'cases') renderCases();
        });
}, 15000);

// Pause auto-refresh when interacting with select
document.addEventListener('focusin', e => {
    if (e.target.tagName === 'SELECT') autoRefresh = false;
});
document.addEventListener('focusout', e => {
    if (e.target.tagName === 'SELECT') autoRefresh = true;
});

// ----------------------
// Initial Load
// ----------------------
const lastTab = localStorage.getItem('activeNGOTab') || 'dashboard';
fetch('/ngo_dashboard_json')
    .then(res => res.json())
    .then(data => {
        casesData = data;
        showSection(lastTab); // This automatically calls renderDashboard or renderCases
    });
// Open modal when clicking photo
function openModal(src, alt) {
    const modal = document.getElementById('photoModal');
    const modalImg = document.getElementById('modalImg');
    const caption = document.getElementById('caption');

    modal.style.display = "block";
    modalImg.src = src;
    caption.textContent = alt;
}

document.querySelector('.modal-close').onclick = function() {
    document.getElementById('photoModal').style.display = "none";
}

document.getElementById('photoModal').onclick = function(e) {
    if(e.target.id === 'photoModal') this.style.display = "none";
}