-- ============================================================
-- AI-Based Tumor Detection Simulation System
-- Database Schema (MySQL)
-- ============================================================

CREATE DATABASE IF NOT EXISTS tumor_detection_db;
USE tumor_detection_db;

-- ============================================================
-- 1. USER Table — stores login credentials
-- ============================================================
CREATE TABLE IF NOT EXISTS `USER` (
    user_id       INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    password      VARCHAR(255) NOT NULL,
    full_name     VARCHAR(100) NOT NULL,
    role          VARCHAR(30)  DEFAULT 'doctor',
    created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 2. PATIENT Table — stores patient details
-- ============================================================
CREATE TABLE IF NOT EXISTS `PATIENT` (
    patient_id      INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    age             INT          NOT NULL,
    gender          VARCHAR(10)  NOT NULL,
    medical_history TEXT,
    contact         VARCHAR(20),
    created_at      TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 3. MEDICAL_IMAGE Table — stores image metadata
-- ============================================================
CREATE TABLE IF NOT EXISTS `MEDICAL_IMAGE` (
    image_id    INT AUTO_INCREMENT PRIMARY KEY,
    patient_id  INT          NOT NULL,
    file_name   VARCHAR(255) NOT NULL,
    file_type   VARCHAR(50)  NOT NULL,
    file_size   VARCHAR(30),
    scan_type   VARCHAR(50)  DEFAULT 'MRI',
    upload_date TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES PATIENT(patient_id) ON DELETE CASCADE
);

-- ============================================================
-- 4. PREDICTION_RESULT Table — stores simulated predictions
-- ============================================================
CREATE TABLE IF NOT EXISTS `PREDICTION_RESULT` (
    prediction_id INT AUTO_INCREMENT PRIMARY KEY,
    image_id      INT          NOT NULL,
    patient_id    INT          NOT NULL,
    score         DOUBLE       NOT NULL,
    severity      VARCHAR(30)  NOT NULL,
    notes         TEXT,
    created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (image_id)   REFERENCES MEDICAL_IMAGE(image_id) ON DELETE CASCADE,
    FOREIGN KEY (patient_id) REFERENCES PATIENT(patient_id)     ON DELETE CASCADE
);

-- ============================================================
-- 5. ACCESS_LOG Table — records system activities
-- ============================================================
CREATE TABLE IF NOT EXISTS `ACCESS_LOG` (
    log_id      INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT          NOT NULL,
    action      VARCHAR(255) NOT NULL,
    ip_address  VARCHAR(50),
    log_time    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES `USER`(user_id) ON DELETE CASCADE
);

-- ============================================================
-- Sample Data
-- ============================================================

-- Users (password is plain text for academic demo; use hashing in production)
INSERT INTO `USER` (username, password, full_name, role) VALUES
('admin',    'admin123',    'Dr. Admin',        'admin'),
('drsmith',  'smith2024',   'Dr. Sarah Smith',  'doctor'),
('drjones',  'jones2024',   'Dr. Mark Jones',   'doctor');

-- Patients
INSERT INTO PATIENT (name, age, gender, medical_history, contact) VALUES
('Rahul Sharma',   45, 'Male',   'Diabetes, Hypertension',                  '9876543210'),
('Priya Patel',    32, 'Female', 'No significant history',                   '9876543211'),
('Amit Kumar',     58, 'Male',   'Previous lung surgery, smoker',            '9876543212'),
('Sneha Reddy',    27, 'Female', 'Family history of breast cancer',          '9876543213'),
('Vikram Singh',   63, 'Male',   'Chronic kidney disease, hypertension',     '9876543214');

-- Medical Images
INSERT INTO MEDICAL_IMAGE (patient_id, file_name, file_type, file_size, scan_type) VALUES
(1, 'brain_scan_001.dcm',  'DICOM', '15.2 MB', 'MRI'),
(2, 'chest_xray_002.png',  'PNG',   '8.7 MB',  'X-Ray'),
(3, 'lung_ct_003.dcm',     'DICOM', '22.1 MB', 'CT Scan'),
(4, 'breast_mri_004.dcm',  'DICOM', '18.5 MB', 'MRI'),
(5, 'kidney_scan_005.dcm', 'DICOM', '12.9 MB', 'CT Scan');

-- Prediction Results
INSERT INTO PREDICTION_RESULT (image_id, patient_id, score, severity, notes) VALUES
(1, 1, 72.5, 'High Risk Tumor',  'Abnormal mass detected in frontal lobe region'),
(2, 2, 18.3, 'No Tumor',         'Chest scan appears normal'),
(3, 3, 55.0, 'Possible Tumor',   'Suspicious nodule in right lung lower lobe'),
(4, 4, 85.2, 'High Risk Tumor',  'Dense mass detected — recommend biopsy'),
(5, 5, 28.7, 'No Tumor',         'Kidney scan within normal parameters');

-- Access Logs
INSERT INTO ACCESS_LOG (user_id, action, ip_address) VALUES
(1, 'LOGIN',                '192.168.1.10'),
(2, 'LOGIN',                '192.168.1.11'),
(2, 'VIEW_PATIENT',         '192.168.1.11'),
(2, 'RUN_PREDICTION',       '192.168.1.11'),
(1, 'VIEW_DASHBOARD',       '192.168.1.10');
