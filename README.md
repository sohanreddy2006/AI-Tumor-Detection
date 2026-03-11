# AI-Based Tumor Detection Simulation System

An academic full-stack web application that simulates how a medical tumor detection system works in a hospital environment. Built with **Java Servlets/JSP**, **MySQL**, and **HTML/CSS/JavaScript**.

> **Note:** This system does not use real AI models. It simulates tumor prediction results using **rule-based logic with random score generation**.

---

## 🏗️ Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│    Frontend      │────▶│     Backend      │────▶│    Database      │
│  HTML/CSS/JS     │     │  Java Servlets   │     │     MySQL        │
│  JSP Pages       │◀────│  JSP Engine      │◀────│  5 Tables        │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

---

## 📁 Project Structure

```
IP/
├── sql/
│   └── schema.sql              # Database DDL + sample data
├── src/com/tumor/
│   ├── model/
│   │   ├── User.java
│   │   ├── Patient.java
│   │   ├── MedicalImage.java
│   │   └── PredictionResult.java
│   ├── servlet/
│   │   ├── LoginServlet.java
│   │   ├── PatientServlet.java
│   │   ├── ImageUploadServlet.java
│   │   ├── PredictionServlet.java
│   │   └── AccessLogServlet.java
│   └── util/
│       └── DBConnection.java
├── web/
│   ├── index.html              # Login page
│   ├── dashboard.jsp           # Main dashboard (SPA-style)
│   ├── css/style.css           # Medical dark theme
│   ├── js/app.js               # AJAX & UI logic
│   └── WEB-INF/web.xml         # Servlet mappings
└── README.md
```

---

## 🗄️ Database Tables

| Table | Purpose |
|-------|---------|
| `USER` | Login credentials & roles |
| `PATIENT` | Patient details (name, age, gender, history) |
| `MEDICAL_IMAGE` | Scan metadata (file name, type, scan type) |
| `PREDICTION_RESULT` | Simulated prediction scores & severity |
| `ACCESS_LOG` | System activity tracking |

---

## ⚙️ Setup & Deployment

### Prerequisites
- **JDK 8+**
- **Apache Tomcat 9+**
- **MySQL 5.7+**
- **MySQL Connector/J** (JDBC driver JAR)

### Steps

1. **Create the database:**
   ```sql
   mysql -u root -p < sql/schema.sql
   ```

2. **Configure DB credentials** in `src/com/tumor/util/DBConnection.java`:
   ```java
   private static final String DB_URL  = "jdbc:mysql://localhost:3306/tumor_detection_db";
   private static final String DB_USER = "root";
   private static final String DB_PASS = "root";  // ← Change this
   ```

3. **Compile and deploy** to Tomcat's `webapps/` directory.

4. **Add MySQL Connector JAR** to `WEB-INF/lib/`.

5. **Access the app** at `http://localhost:8080/TumorDetection/`

### Demo Credentials
| Username | Password |
|----------|----------|
| `admin` | `admin123` |
| `drsmith` | `smith2024` |
| `drjones` | `jones2024` |

---

## 🔒 Security

- All SQL queries use **PreparedStatement** (prevents SQL injection)
- Server-side **session validation** on every protected endpoint
- Client-side + server-side **input validation**

---

## 🎯 Features

- ✅ User authentication with session management
- ✅ Patient CRUD operations
- ✅ Medical image metadata upload
- ✅ Simulated tumor prediction (0–100 score)
- ✅ Severity classification (No Tumor / Possible Tumor / High Risk Tumor)
- ✅ Dynamic dashboard with auto-refresh polling
- ✅ Access logging for all system activities
- ✅ Professional medical-themed dark UI

---

## 📋 System Workflow

```
Login → Dashboard → Add Patient → Upload Scan Metadata → Run Prediction
    → View Results → All Activities Logged
```

---

*Academic Project — AI-Based Tumor Detection Simulation System*
