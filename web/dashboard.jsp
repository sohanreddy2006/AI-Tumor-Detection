<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // ── Session guard ─────────────────────────────────────
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("index.html");
        return;
    }
    String fullName = (String) session.getAttribute("fullName");
    String role     = (String) session.getAttribute("role");
    String initials = "";
    if (fullName != null && fullName.length() > 0) {
        String[] parts = fullName.split(" ");
        for (String p : parts) {
            if (p.length() > 0) initials += p.charAt(0);
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="AI Tumor Detection Dashboard — View patients, predictions, and system analytics.">
    <title>Dashboard — AI Tumor Detection System</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
    <script>
        const savedTheme = localStorage.getItem('theme') || 'dark';
        if (savedTheme === 'light') document.documentElement.setAttribute('data-theme', 'light');
    </script>
</head>
<body>
<div class="app-layout">

    <!-- ═══════════════════════════════════════════════════════
         SIDEBAR
         ═══════════════════════════════════════════════════════ -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-brand">
            <svg viewBox="0 0 48 48" fill="none">
                <circle cx="24" cy="24" r="22" stroke="url(#gSide)" stroke-width="3"/>
                <path d="M24 10v28M10 24h28" stroke="url(#gSide)" stroke-width="3" stroke-linecap="round"/>
                <circle cx="24" cy="24" r="8" stroke="url(#gSide)" stroke-width="2" opacity="0.6"/>
                <defs><linearGradient id="gSide" x1="0" y1="0" x2="48" y2="48">
                    <stop offset="0%" stop-color="#00d4ff"/><stop offset="100%" stop-color="#7c3aed"/>
                </linearGradient></defs>
            </svg>
            <h2>AI Tumor Detection</h2>
        </div>

        <nav class="sidebar-nav">
            <div class="nav-label">Main</div>
            <a href="#" class="nav-item active" data-page="dashboard">
                <svg viewBox="0 0 20 20" fill="currentColor"><path d="M3 4a1 1 0 011-1h12a1 1 0 011 1v2a1 1 0 01-1 1H4a1 1 0 01-1-1V4zm0 6a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H4a1 1 0 01-1-1v-6zm10 0a1 1 0 011-1h2a1 1 0 011 1v6a1 1 0 01-1 1h-2a1 1 0 01-1-1v-6z"/></svg>
                Dashboard
            </a>

            <div class="nav-label">Management</div>
            <a href="#" class="nav-item" data-page="patients">
                <svg viewBox="0 0 20 20" fill="currentColor"><path d="M9 6a3 3 0 11-6 0 3 3 0 016 0zm8 0a3 3 0 11-6 0 3 3 0 016 0zm-4.07 11c.046-.327.07-.66.07-1a6.97 6.97 0 00-1.5-4.33A5 5 0 0119 16v1h-6.07zM6 11a5 5 0 015 5v1H1v-1a5 5 0 015-5z"/></svg>
                Patients
            </a>
            <a href="#" class="nav-item" data-page="upload">
                <svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M3 17a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM6.293 6.707a1 1 0 010-1.414l3-3a1 1 0 011.414 0l3 3a1 1 0 01-1.414 1.414L11 5.414V13a1 1 0 11-2 0V5.414L7.707 6.707a1 1 0 01-1.414 0z" clip-rule="evenodd"/></svg>
                Image Upload
            </a>

            <div class="nav-label">Analysis</div>
            <a href="#" class="nav-item" data-page="prediction">
                <svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M3 3a1 1 0 000 2v8a2 2 0 002 2h2.586l-1.293 1.293a1 1 0 101.414 1.414L10 15.414l2.293 2.293a1 1 0 001.414-1.414L12.414 15H15a2 2 0 002-2V5a1 1 0 100-2H3zm11 4a1 1 0 10-2 0v4a1 1 0 102 0V7zm-3 1a1 1 0 10-2 0v3a1 1 0 102 0V8zM8 9a1 1 0 00-2 0v2a1 1 0 102 0V9z" clip-rule="evenodd"/></svg>
                Predictions
            </a>

            <div class="nav-label">System</div>
            <a href="#" class="nav-item" data-page="logs">
                <svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4z" clip-rule="evenodd"/></svg>
                Access Logs
            </a>
        </nav>

        <div class="sidebar-footer">
            <div class="user-info">
                <div class="user-avatar"><%= initials %></div>
                <div class="user-details">
                    <div class="user-name"><%= fullName %></div>
                    <div class="user-role"><%= role %></div>
                </div>
            </div>
        </div>
    </aside>

    <!-- ═══════════════════════════════════════════════════════
         MAIN CONTENT
         ═══════════════════════════════════════════════════════ -->
    <main class="main-content">
        <div class="topbar">
            <h1 id="pageTitle">Dashboard</h1>
            <div class="topbar-actions">
                <button id="themeToggle" class="btn btn-outline" style="border-radius: 50%; padding: 0.5rem;" title="Toggle Theme">
                    <svg class="sun-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="display:none; width: 18px; height: 18px;"><circle cx="12" cy="12" r="5"></circle><line x1="12" y1="1" x2="12" y2="3"></line><line x1="12" y1="21" x2="12" y2="23"></line><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line><line x1="1" y1="12" x2="3" y2="12"></line><line x1="21" y1="12" x2="23" y2="12"></line><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line><line x1="18.36" y1="4.22" x2="19.78" y2="5.64"></line></svg>
                    <svg class="moon-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width: 18px; height: 18px;"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path></svg>
                </button>
                <span style="font-size:0.82rem;color:var(--text-muted);">
                    <span class="pulse-dot"></span> System Online
                </span>
                <a href="login" class="btn-logout">
                    <svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M3 3a1 1 0 00-1 1v12a1 1 0 001 1h12a1 1 0 001-1V4a1 1 0 00-1-1H3zm10.293 9.293a1 1 0 001.414 1.414l3-3a1 1 0 000-1.414l-3-3a1 1 0 10-1.414 1.414L14.586 9H7a1 1 0 100 2h7.586l-1.293 1.293z" clip-rule="evenodd"/></svg>
                    Logout
                </a>
            </div>
        </div>

        <!-- ═════════════════════════════════════════════════════
             PAGE: DASHBOARD
             ═════════════════════════════════════════════════════ -->
        <div class="page-section active" id="page-dashboard">
            <!-- Stats -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon cyan">
                        <svg viewBox="0 0 20 20" fill="currentColor"><path d="M9 6a3 3 0 11-6 0 3 3 0 016 0zm8 0a3 3 0 11-6 0 3 3 0 016 0zm-4.07 11c.046-.327.07-.66.07-1a6.97 6.97 0 00-1.5-4.33A5 5 0 0119 16v1h-6.07zM6 11a5 5 0 015 5v1H1v-1a5 5 0 015-5z"/></svg>
                    </div>
                    <div class="stat-value" id="statPatients">0</div>
                    <div class="stat-label">Total Patients</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon purple">
                        <svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z" clip-rule="evenodd"/></svg>
                    </div>
                    <div class="stat-value" id="statImages">0</div>
                    <div class="stat-label">Scans Uploaded</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon teal">
                        <svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M3 3a1 1 0 000 2v8a2 2 0 002 2h2.586l-1.293 1.293a1 1 0 101.414 1.414L10 15.414l2.293 2.293a1 1 0 001.414-1.414L12.414 15H15a2 2 0 002-2V5a1 1 0 100-2H3zm11 4a1 1 0 10-2 0v4a1 1 0 102 0V7zm-3 1a1 1 0 10-2 0v3a1 1 0 102 0V8zM8 9a1 1 0 00-2 0v2a1 1 0 102 0V9z" clip-rule="evenodd"/></svg>
                    </div>
                    <div class="stat-value" id="statPredictions">0</div>
                    <div class="stat-label">Predictions Run</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon blue">
                        <svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/></svg>
                    </div>
                    <div class="stat-value" id="statHighRisk">0</div>
                    <div class="stat-label">High Risk Cases</div>
                </div>
            </div>

            <!-- Recent Predictions -->
            <div class="card">
                <div class="card-header">
                    <h3>
                        <svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M3 3a1 1 0 000 2v8a2 2 0 002 2h2.586l-1.293 1.293a1 1 0 101.414 1.414L10 15.414l2.293 2.293a1 1 0 001.414-1.414L12.414 15H15a2 2 0 002-2V5a1 1 0 100-2H3z" clip-rule="evenodd"/></svg>
                        Recent Prediction Results
                    </h3>
                    <span style="font-size:0.75rem;color:var(--text-muted);">Auto-refreshes every 15s</span>
                </div>
                <div class="card-body" style="padding:0;">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Patient</th>
                                <th>Scan File</th>
                                <th>Score</th>
                                <th>Severity</th>
                                <th>Date</th>
                            </tr>
                        </thead>
                        <tbody id="recentPredictions">
                            <tr><td colspan="5" class="empty-state"><p>Loading...</p></td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- ═════════════════════════════════════════════════════
             PAGE: PATIENTS
             ═════════════════════════════════════════════════════ -->
        <div class="page-section" id="page-patients">
            <div class="alert" id="patientAlert"></div>

            <div class="grid-2">
                <!-- Add Patient Form -->
                <div class="card">
                    <div class="card-header">
                        <h3>
                            <svg viewBox="0 0 20 20" fill="currentColor"><path d="M8 9a3 3 0 100-6 3 3 0 000 6zm0 2a6 6 0 016 6H2a6 6 0 016-6zm8-4a1 1 0 10-2 0v1h-1a1 1 0 100 2h1v1a1 1 0 102 0v-1h1a1 1 0 100-2h-1V7z"/></svg>
                            Add New Patient
                        </h3>
                    </div>
                    <div class="card-body">
                        <form id="addPatientForm">
                            <div class="form-row">
                                <div class="form-field">
                                    <label for="patName">Full Name *</label>
                                    <input type="text" id="patName" name="name" required placeholder="Enter patient name">
                                </div>
                                <div class="form-field">
                                    <label for="patAge">Age *</label>
                                    <input type="number" id="patAge" name="age" required min="0" max="150" placeholder="Age">
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="form-field">
                                    <label for="patGender">Gender *</label>
                                    <select id="patGender" name="gender" required>
                                        <option value="">-- Select --</option>
                                        <option value="Male">Male</option>
                                        <option value="Female">Female</option>
                                        <option value="Other">Other</option>
                                    </select>
                                </div>
                                <div class="form-field">
                                    <label for="patContact">Contact</label>
                                    <input type="text" id="patContact" name="contact" placeholder="Phone number">
                                </div>
                            </div>
                            <div class="form-row single">
                                <div class="form-field">
                                    <label for="patHistory">Medical History</label>
                                    <textarea id="patHistory" name="medicalHistory" placeholder="Relevant medical history..."></textarea>
                                </div>
                            </div>
                            <button type="submit" class="btn btn-primary">
                                <svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z" clip-rule="evenodd"/></svg>
                                Add Patient
                            </button>
                        </form>
                    </div>
                </div>

                <!-- Patient List -->
                <div class="card">
                    <div class="card-header">
                        <h3>
                            <svg viewBox="0 0 20 20" fill="currentColor"><path d="M9 6a3 3 0 11-6 0 3 3 0 016 0zm8 0a3 3 0 11-6 0 3 3 0 016 0zm-4.07 11c.046-.327.07-.66.07-1a6.97 6.97 0 00-1.5-4.33A5 5 0 0119 16v1h-6.07zM6 11a5 5 0 015 5v1H1v-1a5 5 0 015-5z"/></svg>
                            Patient Records
                        </h3>
                    </div>
                    <div class="card-body" style="padding:0;">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Name</th>
                                    <th>Age</th>
                                    <th>Gender</th>
                                    <th>History</th>
                                    <th>Contact</th>
                                </tr>
                            </thead>
                            <tbody id="patientTableBody">
                                <tr><td colspan="6" class="empty-state"><p>Loading...</p></td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- ═════════════════════════════════════════════════════
             PAGE: IMAGE UPLOAD
             ═════════════════════════════════════════════════════ -->
        <div class="page-section" id="page-upload">
            <div class="alert" id="uploadAlert"></div>

            <div class="grid-2">
                <!-- Upload Form -->
                <div class="card">
                    <div class="card-header">
                        <h3>
                            <svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M3 17a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM6.293 6.707a1 1 0 010-1.414l3-3a1 1 0 011.414 0l3 3a1 1 0 01-1.414 1.414L11 5.414V13a1 1 0 11-2 0V5.414L7.707 6.707a1 1 0 01-1.414 0z" clip-rule="evenodd"/></svg>
                            Upload Scan Metadata
                        </h3>
                    </div>
                    <div class="card-body">
                        <form id="uploadImageForm">
                            <div class="form-row">
                                <div class="form-field">
                                    <label for="uploadPatientId">Patient *</label>
                                    <select id="uploadPatientId" name="patientId" required>
                                        <option value="">-- Select Patient --</option>
                                    </select>
                                </div>
                                <div class="form-field">
                                    <label for="uploadScanType">Scan Type *</label>
                                    <select id="uploadScanType" name="scanType" required>
                                        <option value="MRI">MRI</option>
                                        <option value="CT Scan">CT Scan</option>
                                        <option value="X-Ray">X-Ray</option>
                                        <option value="PET Scan">PET Scan</option>
                                        <option value="Ultrasound">Ultrasound</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="form-field">
                                    <label for="uploadFileName">File Name *</label>
                                    <input type="text" id="uploadFileName" name="fileName" required placeholder="e.g. brain_scan_006.dcm">
                                </div>
                                <div class="form-field">
                                    <label for="uploadFileType">File Type *</label>
                                    <select id="uploadFileType" name="fileType" required>
                                        <option value="DICOM">DICOM</option>
                                        <option value="PNG">PNG</option>
                                        <option value="JPEG">JPEG</option>
                                        <option value="TIFF">TIFF</option>
                                        <option value="NIfTI">NIfTI</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-row single">
                                <div class="form-field">
                                    <label for="uploadFileSize">File Size</label>
                                    <input type="text" id="uploadFileSize" name="fileSize" placeholder="e.g. 15.2 MB">
                                </div>
                            </div>
                            <button type="submit" class="btn btn-primary">
                                <svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M3 17a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM6.293 6.707a1 1 0 010-1.414l3-3a1 1 0 011.414 0l3 3a1 1 0 01-1.414 1.414L11 5.414V13a1 1 0 11-2 0V5.414L7.707 6.707a1 1 0 01-1.414 0z" clip-rule="evenodd"/></svg>
                                Upload Metadata
                            </button>
                        </form>
                    </div>
                </div>

                <!-- Image List -->
                <div class="card">
                    <div class="card-header">
                        <h3>
                            <svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z" clip-rule="evenodd"/></svg>
                            Uploaded Scans
                        </h3>
                    </div>
                    <div class="card-body" style="padding:0;">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Patient</th>
                                    <th>File Name</th>
                                    <th>Scan Type</th>
                                    <th>Size</th>
                                    <th>Upload Date</th>
                                </tr>
                            </thead>
                            <tbody id="imageTableBody">
                                <tr><td colspan="6" class="empty-state"><p>Loading...</p></td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- ═════════════════════════════════════════════════════
             PAGE: PREDICTIONS
             ═════════════════════════════════════════════════════ -->
        <div class="page-section" id="page-prediction">
            <div class="alert" id="predictionAlert"></div>

            <div class="grid-2">
                <!-- Run Prediction -->
                <div class="card">
                    <div class="card-header">
                        <h3>
                            <svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M11.3 1.046A1 1 0 0112 2v5h4a1 1 0 01.82 1.573l-7 10A1 1 0 018 18v-5H4a1 1 0 01-.82-1.573l7-10a1 1 0 011.12-.38z" clip-rule="evenodd"/></svg>
                            Run Tumor Prediction
                        </h3>
                    </div>
                    <div class="card-body">
                        <form id="runPredictionForm">
                            <div class="form-row">
                                <div class="form-field">
                                    <label for="predictImageId">Select Scan Image *</label>
                                    <select id="predictImageId" name="imageId" required>
                                        <option value="">-- Select Image --</option>
                                    </select>
                                </div>
                                <div class="form-field">
                                    <label for="predictPatientId">Patient ID</label>
                                    <input type="number" id="predictPatientId" name="patientId" required readonly placeholder="Auto-filled">
                                </div>
                            </div>
                            <button type="submit" class="btn btn-success">
                                <svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M11.3 1.046A1 1 0 0112 2v5h4a1 1 0 01.82 1.573l-7 10A1 1 0 018 18v-5H4a1 1 0 01-.82-1.573l7-10a1 1 0 011.12-.38z" clip-rule="evenodd"/></svg>
                                Run AI Prediction
                            </button>
                        </form>

                        <!-- Prediction Result Display -->
                        <div id="predictionResult" style="display:none; margin-top:1.5rem; border-top: 1px solid var(--border-color); padding-top:1.5rem;">
                            <div class="prediction-display">
                                <div class="prediction-score-circle" id="predScoreCircle">
                                    <span class="prediction-score-value" id="predScoreValue">0%</span>
                                </div>
                                <div class="prediction-severity" id="predSeverity">—</div>
                                <div class="prediction-notes" id="predNotes"></div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Prediction History -->
                <div class="card">
                    <div class="card-header">
                        <h3>
                            <svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M3 3a1 1 0 000 2v8a2 2 0 002 2h2.586l-1.293 1.293a1 1 0 101.414 1.414L10 15.414l2.293 2.293a1 1 0 001.414-1.414L12.414 15H15a2 2 0 002-2V5a1 1 0 100-2H3z" clip-rule="evenodd"/></svg>
                            Prediction History
                        </h3>
                    </div>
                    <div class="card-body" style="padding:0;">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Patient</th>
                                    <th>Scan</th>
                                    <th>Score</th>
                                    <th>Severity</th>
                                    <th>Date</th>
                                </tr>
                            </thead>
                            <tbody id="predictionTableBody">
                                <tr><td colspan="6" class="empty-state"><p>Loading...</p></td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- ═════════════════════════════════════════════════════
             PAGE: ACCESS LOGS
             ═════════════════════════════════════════════════════ -->
        <div class="page-section" id="page-logs">
            <div class="card">
                <div class="card-header">
                    <h3>
                        <svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4z" clip-rule="evenodd"/></svg>
                        System Access Logs
                    </h3>
                    <span style="font-size:0.75rem;color:var(--text-muted);">Last 50 entries</span>
                </div>
                <div class="card-body" style="padding:0;">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Log ID</th>
                                <th>User</th>
                                <th>Action</th>
                                <th>IP Address</th>
                                <th>Timestamp</th>
                            </tr>
                        </thead>
                        <tbody id="logTableBody">
                            <tr><td colspan="5" class="empty-state"><p>Loading...</p></td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </main>
</div>

<!-- Loading Overlay -->
<div class="loading-overlay" id="loadingOverlay">
    <div class="loading-spinner"></div>
</div>

<script src="js/app.js"></script>
</body>
</html>
