<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Session Security Check
    if (session.getAttribute("userId") == null || !"patient".equals(session.getAttribute("role"))) {
        response.sendRedirect("index.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patient Dashboard — AI Tumor Detection</title    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- External Libraries -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.25/jspdf.plugin.autotable.min.js"></script>

    <style>
        :root {
            --bg: #0f0f1a;
            --bg-card: #1a1a2e;
            --text: #e0e0f0;
            --text-muted: #8888aa;
            --accent: #00d4ff;
            --border: #2e2e50;
            --success: #22c55e;
            --warn: #f59e0b;
        }

        [data-theme="light"] {
            --bg: #f0f2f8;
            --bg-card: #ffffff;
            --text: #1a1a2e;
            --text-muted: #555577;
            --accent: #5a6ff0;
            --border: #ccccdd;
        }

        * { margin:0; padding:0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body { background: var(--bg); color: var(--text); min-height: 100vh; transition: 0.4s; overflow-x: hidden;}

        header {
            padding: 1.2rem 2rem;
            background: var(--bg-card);
            border-bottom: 1px solid var(--border);
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: sticky; top: 0; z-index: 100;
        }

        .user-info { display: flex; align-items: center; gap: 12px; }
        .user-info i { font-size: 2.2rem; color: var(--accent); }

        .container { max-width: 1200px; margin: 1.5rem auto; padding: 0 1.5rem; }
        
        .welcome-card {
            background: linear-gradient(135deg, var(--accent), #7c3aed);
            border-radius: 20px;
            padding: 2rem;
            color: white;
            margin-bottom: 1.5rem;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            display: flex; justify-content: space-between; align-items: center;
        }

        .grid-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; }
        
        .section-title { font-size: 1.2rem; font-weight: 600; display: flex; align-items: center; gap: 8px; }
        .section-title i { color: var(--accent); }

        /* Dashboard Tabs */
        .dash-tabs { display: flex; gap: 1rem; margin-bottom: 2rem; border-bottom: 1px solid var(--border); padding-bottom: 0.5rem; }
        .tab-btn { background: none; border: none; color: var(--text-muted); padding: 0.5rem 1rem; cursor: pointer; font-weight: 500; transition: 0.3s; border-radius: 8px; }
        .tab-btn.active { color: var(--accent); background: rgba(0, 212, 255, 0.1); }
        .tab-content { display: none; }
        .tab-content.active { display: block; animation: fadeIn 0.4s; }

        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

        .reports-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 1.5rem;
        }

        .report-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 1.5rem;
            transition: 0.3s;
            position: relative;
        }

        .report-card:hover { transform: translateY(-5px); border-color: var(--accent); box-shadow: 0 10px 20px rgba(0,0,0,0.1); }

        .btn-logout { color: #ff4757; text-decoration: none; display: flex; align-items: center; gap: 6px; font-weight: 600; }

        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            background: rgba(0, 212, 255, 0.1);
            color: var(--accent);
            margin-top: 1rem;
        }

        .btn-download {
            margin-top: 1rem;
            width: 100%;
            padding: 10px;
            border: 1.5px solid var(--accent);
            background: none;
            color: var(--accent);
            border-radius: 10px;
            cursor: pointer;
            font-weight: 600;
            display: flex; justify-content: center; align-items: center; gap: 8px;
            transition: 0.3s;
        }
        .btn-download:hover { background: var(--accent); color: white; }

        /* Chart card */
        .chart-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            height: 350px;
        }

        /* Appointment Form */
        .booking-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 1.5rem;
        }
        .form-group { margin-bottom: 1.2rem; }
        .form-group label { display: block; font-size: 0.85rem; color: var(--text-muted); margin-bottom: 6px; }
        .form-group input, .form-group textarea, .form-group select {
            width: 100%; padding: 12px; background: var(--bg); border: 1px solid var(--border);
            color: var(--text); border-radius: 10px; outline: none; transition: 0.3s;
        }
        .form-group input:focus { border-color: var(--accent); }
        .btn-book {
            width: 100%; padding: 14px; background: var(--accent); color: white; border: none;
            border-radius: 10px; font-weight: 600; cursor: pointer; transition: 0.3s;
        }
        .btn-book:hover { background: #00b8e6; transform: scale(1.02); }

        .appointment-list { display: flex; flex-direction: column; gap: 1rem; }
        .app-item {
            background: var(--bg); border-left: 4px solid var(--accent); padding: 1rem; border-radius: 10px;
            display: flex; justify-content: space-between; align-items: center;
        }
        .app-status { font-size: 0.8rem; padding: 4px 10px; border-radius: 8px; background: rgba(34, 197, 94, 0.1); color: var(--success); }
    </style>
</head>
<body data-theme="dark">
    <script>
        const savedTheme = localStorage.getItem('theme') || 'dark';
        document.body.setAttribute('data-theme', savedTheme);
    </script>

    <header>
        <div class="user-info">
            <i class='bx bxs-user-circle'></i>
            <div>
                <p style="font-size: 0.75rem; color: var(--text-muted);">Patient Portal</p>
                <h2 style="font-size: 1rem;"><%= session.getAttribute("fullName") %></h2>
            </div>
        </div>
        <div style="display: flex; gap: 1.5rem; align-items: center;">
            <a href="login" class="btn-logout"><i class='bx bx-log-out'></i> Logout</a>
        </div>
    </header>

    <div class="container" id="dashboard">
        <div class="welcome-card">
            <div>
                <h1 style="font-size: 1.8rem; margin-bottom: 8px;">Hello, <%= session.getAttribute("fullName") %></h1>
                <p style="opacity: 0.9;">Manage your scans, track trends, and schedule appointments.</p>
            </div>
            <i class='bx bxs-brain' style="font-size: 4rem; opacity: 0.2;"></i>
        </div>

        <div class="dash-tabs">
            <button class="tab-btn active" data-tab="reports">Medical Reports</button>
            <button class="tab-btn" data-tab="trends">Health Trends</button>
            <button class="tab-btn" data-tab="appointments">Appointments</button>
        </div>

        <!-- ── Reports Tab ───────────────────────────── -->
        <div class="tab-content active" id="tab-reports">
            <div class="grid-header">
                <div class="section-title"><i class='bx bx-file'></i> Available Reports</div>
            </div>
            <div class="reports-grid" id="reportsGrid">
                <div class="report-card" style="text-align: center; grid-column: 1/-1; padding: 3rem;">
                    <p>Fetching your latest results...</p>
                </div>
            </div>
        </div>

        <!-- ── Trends Tab ────────────────────────────── -->
        <div class="tab-content" id="tab-trends">
            <div class="section-title" style="margin-bottom: 1.5rem;"><i class='bx bx-line-chart'></i> Prediction Score Analytics</div>
            <div class="chart-card">
                <canvas id="trendsChart"></canvas>
            </div>
            <p style="font-size: 0.85rem; color: var(--text-muted); text-align: center;">This chart visualizes the AI confidence scores from your historical scans.</p>
        </div>

        <!-- ── Appointments Tab ──────────────────────── -->
        <div class="tab-content" id="tab-appointments">
            <div style="display: grid; grid-template-columns: 1fr 1.5fr; gap: 2rem;">
                <div class="booking-card">
                    <div class="section-title" style="margin-bottom: 1.2rem;"><i class='bx bx-calendar-plus'></i> Book Follow-up</div>
                    <form id="bookingForm">
                        <div class="form-group">
                            <label>Doctor Name</label>
                            <input type="text" name="doctorName" required placeholder="Dr. Smith">
                        </div>
                        <div class="form-group">
                            <label>Preferred Date & Time</label>
                            <input type="datetime-local" name="appDate" required>
                        </div>
                        <div class="form-group">
                            <label>Reason / Notes</label>
                            <textarea name="reason" rows="3" placeholder="Consultation for MRI results..."></textarea>
                        </div>
                        <button type="submit" class="btn-book">Schedule Appointment</button>
                    </form>
                </div>
                <div>
                    <div class="section-title" style="margin-bottom: 1.2rem;"><i class='bx bx-list-check'></i> Your Appointments</div>
                    <div class="appointment-list" id="appointmentList">
                        <p style="color: var(--text-muted);">No upcoming appointments yet.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // ── Tab Logic ──────────────────────────────────────────
        const tabs = document.querySelectorAll('.tab-btn');
        const contents = document.querySelectorAll('.tab-content');

        tabs.forEach(tab => {
            tab.addEventListener('click', () => {
                tabs.forEach(t => t.classList.remove('active'));
                contents.forEach(c => c.classList.remove('active'));
                tab.classList.add('active');
                document.getElementById('tab-' + tab.dataset.tab).classList.add('active');
                
                if (tab.dataset.tab === 'trends') renderTrends();
                if (tab.dataset.tab === 'appointments') loadAppointments();
            });
        });

        // ── Data Fetching & Rendering ──────────────────────────
        let globalReports = [];

        function loadReports() {
            const grid = document.getElementById('reportsGrid');
            fetch('predict')
                .then(r => r.json())
                .then(data => {
                    globalReports = data;
                    if (!data || data.length === 0) {
                        grid.innerHTML = `
                            <div class="report-card" style="display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center; opacity: 0.6; grid-column: 1/-1; padding: 3rem;">
                                <i class='bx bx-plus-circle' style="font-size: 2rem; margin-bottom: 0.5rem;"></i>
                                <p style="font-size: 0.9rem;">No reports found. Results will appear here after your doctor's review.</p>
                            </div>`;
                        return;
                    }

                    grid.innerHTML = data.map((p, idx) => `
                        <div class="report-card">
                            <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                                <div>
                                    <p style="font-size: 0.75rem; color: var(--text-muted);">\${formatDate(p.createdAt)}</p>
                                    <h4 style="margin: 4px 0;">\${p.tumorType || 'MRI Scan Analysis'}</h4>
                                </div>
                                <i class='bx bx-file' style="font-size: 1.5rem; color: var(--accent);"></i>
                            </div>
                            <div style="margin-top: 1rem;">
                                <div style="display: flex; justify-content: space-between; font-size: 0.85rem; margin-bottom: 5px;">
                                    <span>AI Confidence</span>
                                    <strong>\${p.score.toFixed(1)}%</strong>
                                </div>
                                <div style="height: 6px; background: var(--border); border-radius: 3px; overflow: hidden;">
                                    <div style="width: \${p.score}%; height: 100%; background: \${getScoreColor(p.score)};"></div>
                                </div>
                            </div>
                            <p style="font-size: 0.8rem; color: var(--text-muted); margin-top: 1rem;">Severity: <span style="color: \${getScoreColor(p.score)}">\${p.severity}</span></p>
                            <button class="btn-download" onclick="generatePDF(\${idx})">
                                <i class='bx bx-download'></i> Download Report PDF
                            </button>
                        </div>
                    `).join('');
                });
        }

        // ── Charting ───────────────────────────────────────────
        let myChart = null;
        function renderTrends() {
            const ctx = document.getElementById('trendsChart').getContext('2d');
            if (myChart) myChart.destroy();

            // Sort reports chronologically for the trend
            const sorted = [...globalReports].sort((a,b) => new Date(a.createdAt) - new Date(b.createdAt));
            const labels = sorted.map(r => new Date(r.createdAt).toLocaleDateString('en-IN', {day:'numeric', month:'short'}));
            const scores = sorted.map(r => r.score);

            myChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Tumor Probability Score (%)',
                        data: scores,
                        borderColor: '#00d4ff',
                        backgroundColor: 'rgba(0, 212, 255, 0.1)',
                        fill: true,
                        tension: 0.4,
                        pointRadius: 6,
                        pointBackgroundColor: '#00d4ff'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: { beginAtZero: true, max: 100, grid: { color: 'rgba(255,255,255,0.05)' } },
                        x: { grid: { display: false } }
                    }
                }
            });
        }

        // ── PDF Generation ─────────────────────────────────────
        function generatePDF(index) {
            const r = globalReports[index];
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF();
            
            // Header
            doc.setFillColor(0, 212, 255);
            doc.rect(0, 0, 210, 30, 'F');
            doc.setTextColor(255, 255, 255);
            doc.setFontSize(20);
            doc.text('AI Tumor Detection System', 15, 20);
            
            // Info
            doc.setTextColor(0, 0, 0);
            doc.setFontSize(14);
            doc.text('Medical Simulation Report', 15, 45);
            
            doc.autoTable({
                startY: 55,
                head: [['Field', 'Detail']],
                body: [
                    ['Patient Name', '<%= session.getAttribute("fullName") %>'],
                    ['Report Date', formatDate(r.createdAt)],
                    ['Scan File', r.fileName],
                    ['Tumor Type', r.tumorType],
                    ['AI Score', r.score.toFixed(2) + '%'],
                    ['Severity', r.severity]
                ],
                theme: 'striped'
            });

            doc.setFontSize(12);
            doc.text('Clinical Notes:', 15, doc.lastAutoTable.finalY + 15);
            doc.setFontSize(10);
            const notes = doc.splitTextToSize(r.notes || "No additional notes provided.", 180);
            doc.text(notes, 15, doc.lastAutoTable.finalY + 22);

            doc.text('Recommendation:', 15, doc.lastAutoTable.finalY + 40);
            const rec = doc.splitTextToSize(r.recommendation || "Consult with your physician for further analysis.", 180);
            doc.text(rec, 15, doc.lastAutoTable.finalY + 47);

            doc.save(\`Medical_Report_\${pName().replace(' ','_')}_\${index}.pdf\`);
        }

        // ── Appointment Management ───────────────────────────────
        function loadAppointments() {
            const list = document.getElementById('appointmentList');
            fetch('booking')
                .then(r => r.json())
                .then(data => {
                    if (data.length === 0) {
                        list.innerHTML = '<p style="color: var(--text-muted); padding: 1rem;">No upcoming appointments yet.</p>';
                        return;
                    }
                    list.innerHTML = data.map(a => `
                        <div class="app-item">
                            <div>
                                <h4 style="margin-bottom: 4px;">\${a.doctorName}</h4>
                                <p style="font-size: 0.8rem; color: var(--text-muted);"><i class='bx bx-calendar'></i> \${new Date(a.appDate).toLocaleString()}</p>
                                <p style="font-size: 0.75rem; margin-top: 4px; font-style: italic;">"\${a.reason}"</p>
                            </div>
                            <span class="app-status">\${a.status}</span>
                        </div>
                    `).join('');
                });
        }

        document.getElementById('bookingForm').addEventListener('submit', function(e) {
            e.preventDefault();
            const formData = new URLSearchParams(new FormData(this));
            fetch('booking', { method: 'POST', body: formData })
                .then(r => r.json())
                .then(data => {
                    if (data.success) {
                        alert('Appointment Requested! Check your list.');
                        this.reset();
                        loadAppointments();
                    } else alert('Error: ' + data.error);
                });
        });

        // ── Helpers ──────────────────────────────────────────────
        function formatDate(dateStr) {
            const d = new Date(dateStr);
            return d.toLocaleDateString('en-IN', { day:'2-digit', month:'short', year:'numeric' }) + ' ' + d.toLocaleTimeString('en-IN', {hour:'2-digit', minute:'2-digit'});
        }
        function getScoreColor(score) {
            if (score > 60) return '#ef4444'; // Danger
            if (score > 30) return '#f59e0b'; // Warn
            return '#22c55e'; // Safe
        }
        function pName() { return '<%= session.getAttribute("fullName") %>'; }

        loadReports();
    </script>
</body>
</html>
>
