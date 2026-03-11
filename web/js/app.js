/* ============================================================
   AI-Based Tumor Detection Simulation System
   Frontend Application Logic — app.js
   ============================================================ */

(function () {
    'use strict';

    // ── API Endpoints ─────────────────────────────────────────
    const API = {
        patients:    'patients',
        upload:      'upload',
        predict:     'predict',
        logs:        'logs',
        login:       'login'
    };

    // ── Navigation ────────────────────────────────────────────
    const navItems = document.querySelectorAll('.nav-item[data-page]');
    const sections = document.querySelectorAll('.page-section');

    function navigateTo(page) {
        sections.forEach(s => s.classList.remove('active'));
        navItems.forEach(n => n.classList.remove('active'));

        const target = document.getElementById('page-' + page);
        const navTarget = document.querySelector('.nav-item[data-page="' + page + '"]');
        if (target) target.classList.add('active');
        if (navTarget) navTarget.classList.add('active');

        // Update topbar title
        const titles = {
            dashboard:  'Dashboard',
            patients:   'Patient Management',
            upload:     'Image Upload',
            prediction: 'Prediction Results',
            logs:       'Access Logs'
        };
        const topTitle = document.getElementById('pageTitle');
        if (topTitle) topTitle.textContent = titles[page] || 'Dashboard';

        // Load data for the page
        if (page === 'dashboard')  loadDashboard();
        if (page === 'patients')   loadPatients();
        if (page === 'upload')     { loadImages(); loadPatientDropdown('uploadPatientId'); }
        if (page === 'prediction') { loadPredictions(); loadImageDropdown(); }
        if (page === 'logs')       loadLogs();
    }

    navItems.forEach(item => {
        item.addEventListener('click', function (e) {
            e.preventDefault();
            navigateTo(this.dataset.page);
        });
    });

    // ── Dashboard ─────────────────────────────────────────────
    function loadDashboard() {
        // Load stats
        fetch(API.patients).then(r => r.json()).then(data => {
            document.getElementById('statPatients').textContent = data.length;
        }).catch(() => {});

        fetch(API.upload).then(r => r.json()).then(data => {
            document.getElementById('statImages').textContent = data.length;
        }).catch(() => {});

        fetch(API.predict).then(r => r.json()).then(data => {
            document.getElementById('statPredictions').textContent = data.length;
            const highRisk = data.filter(d => d.severity === 'High Risk Tumor').length;
            document.getElementById('statHighRisk').textContent = highRisk;

            // Recent predictions table
            renderRecentPredictions(data.slice(0, 5));
        }).catch(() => {});
    }

    function renderRecentPredictions(predictions) {
        const tbody = document.getElementById('recentPredictions');
        if (!tbody) return;
        if (predictions.length === 0) {
            tbody.innerHTML = '<tr><td colspan="5" class="empty-state"><p>No predictions yet.</p></td></tr>';
            return;
        }
        tbody.innerHTML = predictions.map(p => `
            <tr>
                <td><strong>${escHtml(p.patientName)}</strong></td>
                <td>${escHtml(p.fileName)}</td>
                <td>
                    <div class="score-bar">
                        <div class="score-track">
                            <div class="score-fill ${severityClass(p.severity)}" style="width:${p.score}%"></div>
                        </div>
                        <span class="score-value">${p.score.toFixed(1)}%</span>
                    </div>
                </td>
                <td><span class="badge badge-${severityClass(p.severity)}">${escHtml(p.severity)}</span></td>
                <td>${formatDate(p.createdAt)}</td>
            </tr>
        `).join('');
    }

    // ── Patients ──────────────────────────────────────────────
    function loadPatients() {
        fetch(API.patients)
            .then(r => r.json())
            .then(data => {
                const tbody = document.getElementById('patientTableBody');
                if (!tbody) return;
                if (data.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6" class="empty-state"><p>No patients registered.</p></td></tr>';
                    return;
                }
                tbody.innerHTML = data.map(p => `
                    <tr>
                        <td><strong>#${p.patientId}</strong></td>
                        <td>${escHtml(p.name)}</td>
                        <td>${p.age}</td>
                        <td>${escHtml(p.gender)}</td>
                        <td>${escHtml(p.medicalHistory)}</td>
                        <td>${escHtml(p.contact)}</td>
                    </tr>
                `).join('');
            })
            .catch(() => showAlert('patientAlert', 'Failed to load patients.', 'error'));
    }

    // Add patient form
    const patientForm = document.getElementById('addPatientForm');
    if (patientForm) {
        patientForm.addEventListener('submit', function (e) {
            e.preventDefault();
            const formData = new URLSearchParams(new FormData(this));

            fetch(API.patients, { method: 'POST', body: formData })
                .then(r => r.json())
                .then(data => {
                    if (data.success) {
                        showAlert('patientAlert', 'Patient added successfully! ID: ' + data.patientId, 'success');
                        this.reset();
                        loadPatients();
                    } else {
                        showAlert('patientAlert', data.error || 'Failed to add patient.', 'error');
                    }
                })
                .catch(() => showAlert('patientAlert', 'Network error.', 'error'));
        });
    }

    // ── Image Upload ──────────────────────────────────────────
    function loadImages() {
        fetch(API.upload)
            .then(r => r.json())
            .then(data => {
                const tbody = document.getElementById('imageTableBody');
                if (!tbody) return;
                if (data.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6" class="empty-state"><p>No images uploaded.</p></td></tr>';
                    return;
                }
                tbody.innerHTML = data.map(img => `
                    <tr>
                        <td><strong>#${img.imageId}</strong></td>
                        <td>${escHtml(img.patientName)}</td>
                        <td>${escHtml(img.fileName)}</td>
                        <td>${escHtml(img.scanType)}</td>
                        <td>${escHtml(img.fileSize)}</td>
                        <td>${formatDate(img.uploadDate)}</td>
                    </tr>
                `).join('');
            })
            .catch(() => showAlert('uploadAlert', 'Failed to load images.', 'error'));
    }

    const uploadForm = document.getElementById('uploadImageForm');
    if (uploadForm) {
        uploadForm.addEventListener('submit', function (e) {
            e.preventDefault();
            const formData = new URLSearchParams(new FormData(this));

            fetch(API.upload, { method: 'POST', body: formData })
                .then(r => r.json())
                .then(data => {
                    if (data.success) {
                        showAlert('uploadAlert', 'Image metadata uploaded! ID: ' + data.imageId, 'success');
                        this.reset();
                        loadImages();
                    } else {
                        showAlert('uploadAlert', data.error || 'Upload failed.', 'error');
                    }
                })
                .catch(() => showAlert('uploadAlert', 'Network error.', 'error'));
        });
    }

    // ── Predictions ───────────────────────────────────────────
    function loadPredictions() {
        fetch(API.predict)
            .then(r => r.json())
            .then(data => {
                const tbody = document.getElementById('predictionTableBody');
                if (!tbody) return;
                if (data.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6" class="empty-state"><p>No predictions generated.</p></td></tr>';
                    return;
                }
                tbody.innerHTML = data.map(p => `
                    <tr>
                        <td><strong>#${p.predictionId}</strong></td>
                        <td>${escHtml(p.patientName)}</td>
                        <td>${escHtml(p.fileName)}</td>
                        <td>
                            <div class="score-bar">
                                <div class="score-track">
                                    <div class="score-fill ${severityClass(p.severity)}" style="width:${p.score}%"></div>
                                </div>
                                <span class="score-value">${p.score.toFixed(1)}%</span>
                            </div>
                        </td>
                        <td><span class="badge badge-${severityClass(p.severity)}">${escHtml(p.severity)}</span></td>
                        <td>${formatDate(p.createdAt)}</td>
                    </tr>
                `).join('');
            })
            .catch(() => showAlert('predictionAlert', 'Failed to load predictions.', 'error'));
    }

    // Run prediction
    const predictForm = document.getElementById('runPredictionForm');
    if (predictForm) {
        predictForm.addEventListener('submit', function (e) {
            e.preventDefault();
            const formData = new URLSearchParams(new FormData(this));
            const resultDiv = document.getElementById('predictionResult');
            resultDiv.style.display = 'none';

            fetch(API.predict, { method: 'POST', body: formData })
                .then(r => r.json())
                .then(data => {
                    if (data.success) {
                        showPredictionResult(data);
                        loadPredictions();
                    } else {
                        showAlert('predictionAlert', data.error || 'Prediction failed.', 'error');
                    }
                })
                .catch(() => showAlert('predictionAlert', 'Network error.', 'error'));
        });
    }

    function showPredictionResult(data) {
        const resultDiv = document.getElementById('predictionResult');
        const scoreEl   = document.getElementById('predScoreValue');
        const sevEl     = document.getElementById('predSeverity');
        const notesEl   = document.getElementById('predNotes');
        const circle    = document.getElementById('predScoreCircle');

        if (!resultDiv) return;

        scoreEl.textContent = data.score.toFixed(1) + '%';
        sevEl.textContent   = data.severity;
        notesEl.textContent = data.notes;

        const cls = severityClass(data.severity);
        const colors = { safe: '#22c55e', warn: '#f59e0b', danger: '#ef4444' };
        circle.style.setProperty('--fill-color', colors[cls]);
        circle.style.setProperty('--fill-pct', data.score + '%');

        sevEl.className = 'prediction-severity';
        scoreEl.style.color = colors[cls];
        sevEl.style.color   = colors[cls];

        resultDiv.style.display = 'block';
        resultDiv.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }

    // ── Access Logs ───────────────────────────────────────────
    function loadLogs() {
        fetch(API.logs)
            .then(r => r.json())
            .then(data => {
                const tbody = document.getElementById('logTableBody');
                if (!tbody) return;
                if (data.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="5" class="empty-state"><p>No logs recorded.</p></td></tr>';
                    return;
                }
                tbody.innerHTML = data.map(l => `
                    <tr>
                        <td><strong>#${l.logId}</strong></td>
                        <td>${escHtml(l.fullName)}</td>
                        <td><span class="badge badge-${actionClass(l.action)}">${escHtml(l.action)}</span></td>
                        <td>${escHtml(l.ipAddress)}</td>
                        <td>${formatDate(l.logTime)}</td>
                    </tr>
                `).join('');
            })
            .catch(() => {});
    }

    // ── Dropdown loaders ──────────────────────────────────────
    function loadPatientDropdown(selectId) {
        fetch(API.patients)
            .then(r => r.json())
            .then(data => {
                const sel = document.getElementById(selectId);
                if (!sel) return;
                sel.innerHTML = '<option value="">-- Select Patient --</option>';
                data.forEach(p => {
                    sel.innerHTML += `<option value="${p.patientId}">${p.name} (ID: ${p.patientId})</option>`;
                });
            })
            .catch(() => {});
    }

    function loadImageDropdown() {
        fetch(API.upload)
            .then(r => r.json())
            .then(data => {
                const sel = document.getElementById('predictImageId');
                if (!sel) return;
                sel.innerHTML = '<option value="">-- Select Image --</option>';
                data.forEach(img => {
                    sel.innerHTML += `<option value="${img.imageId}" data-patient="${img.patientId}">${img.fileName} — ${img.patientName} (ID: ${img.imageId})</option>`;
                });

                // Auto-fill patient ID when image selected
                sel.addEventListener('change', function () {
                    const opt = this.options[this.selectedIndex];
                    const pidField = document.getElementById('predictPatientId');
                    if (pidField && opt.dataset.patient) {
                        pidField.value = opt.dataset.patient;
                    }
                });
            })
            .catch(() => {});
    }

    // ── Polling (auto-refresh predictions on dashboard) ──────
    let pollInterval;
    function startPolling() {
        pollInterval = setInterval(() => {
            const activePage = document.querySelector('.page-section.active');
            if (activePage && activePage.id === 'page-dashboard') {
                loadDashboard();
            }
        }, 15000); // every 15 seconds
    }

    function stopPolling() {
        if (pollInterval) clearInterval(pollInterval);
    }

    // ── Helpers ───────────────────────────────────────────────
    function severityClass(severity) {
        if (severity === 'No Tumor')         return 'safe';
        if (severity === 'Possible Tumor')   return 'warn';
        if (severity === 'High Risk Tumor')  return 'danger';
        return 'safe';
    }

    function actionClass(action) {
        if (action === 'LOGIN' || action === 'LOGOUT') return 'safe';
        if (action === 'RUN_PREDICTION') return 'warn';
        return 'safe';
    }

    function escHtml(str) {
        if (!str) return '';
        const div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }

    function formatDate(dateStr) {
        if (!dateStr) return '-';
        const d = new Date(dateStr);
        if (isNaN(d.getTime())) return dateStr;
        return d.toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' }) + ' ' +
               d.toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit' });
    }

    function showAlert(id, message, type) {
        const el = document.getElementById(id);
        if (!el) return;
        el.className = 'alert alert-' + type + ' show';
        el.innerHTML = message;
        setTimeout(() => { el.classList.remove('show'); }, 5000);
    }

    // ── Init ──────────────────────────────────────────────────
    navigateTo('dashboard');
    startPolling();

    // Expose for inline use
    window.TumorApp = { navigateTo, loadPatients, loadImages, loadPredictions, loadLogs };

})();
