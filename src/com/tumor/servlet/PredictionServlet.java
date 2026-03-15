package com.tumor.servlet;

import com.tumor.util.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.util.Random;

/**
 * Simulates AI tumor prediction.
 * POST /predict — generates random score, classifies severity, stores result.
 * GET  /predict — returns all prediction results as JSON.
 */
public class PredictionServlet extends HttpServlet {

    private static final Random random = new Random();

    @Override
    public void init() throws ServletException {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            Statement stmt = conn.createStatement();
            
            // Auto-patch for existing databases
            try { stmt.execute("ALTER TABLE PREDICTION_RESULT ADD COLUMN tumor_type VARCHAR(50)"); } catch (Exception e) {}
            try { stmt.execute("ALTER TABLE PREDICTION_RESULT ADD COLUMN recommendation TEXT"); } catch (Exception e) {}
            
            stmt.close();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeConnection(conn);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Unauthorized\"}");
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String imageIdStr   = request.getParameter("imageId");
        String patientIdStr = request.getParameter("patientId");

        // ── Validation ────────────────────────────────────────
        if (imageIdStr == null || patientIdStr == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Image ID and Patient ID are required.\"}");
            return;
        }

        int imageId, patientId;
        try {
            imageId   = Integer.parseInt(imageIdStr.trim());
            patientId = Integer.parseInt(patientIdStr.trim());
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Invalid ID values.\"}");
            return;
        }

        // ── Generate simulated prediction ─────────────────────
        double score = Math.round(random.nextDouble() * 10000.0) / 100.0; // 0.00 – 100.00
        String severity;
        String notes;
        String tumorType;
        String recommendation;

        if (score <= 30) {
            severity = "No Tumor";
            tumorType = "Normal";
            notes = "Scan analysis indicates no significant abnormalities detected.";
            recommendation = "Maintain routine screening. Next follow-up scan in 12 months.";
        } else if (score <= 60) {
            severity = "Possible Tumor";
            tumorType = random.nextBoolean() ? "Benign Mass" : "Meningioma (Low Grade)";
            notes = "Suspicious region identified — further diagnostic evaluation recommended.";
            recommendation = "Schedule Contrast-Enhanced MRI and follow-up with a neurologist within 30 days.";
        } else {
            severity = "High Risk Tumor";
            tumorType = random.nextBoolean() ? "Glioma" : "Pituitary Tumor";
            notes = "High-confidence anomaly detected — immediate specialist consultation advised.";
            recommendation = "Urgent: Immediate neurosurgical consultation and biopsy required for definitive diagnosis.";
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            String sql = "INSERT INTO PREDICTION_RESULT (image_id, patient_id, score, severity, notes, tumor_type, recommendation) VALUES (?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            try {
                ps.setInt(1, imageId);
                ps.setInt(2, patientId);
                ps.setDouble(3, score);
                ps.setString(4, severity);
                ps.setString(5, notes);
                ps.setString(6, tumorType);
                ps.setString(7, recommendation);
                ps.executeUpdate();

                ResultSet keys = ps.getGeneratedKeys();
                int predictionId = 0;
                try {
                    if (keys.next()) {
                        predictionId = keys.getInt(1);
                    }
                } finally {
                    keys.close();
                }

                // Log the activity
                logAccess(conn, (Integer) session.getAttribute("userId"), "RUN_PREDICTION", request.getRemoteAddr());

                StringBuilder json = new StringBuilder("{");
                json.append("\"success\":true,");
                json.append("\"predictionId\":").append(predictionId).append(",");
                json.append("\"score\":").append(score).append(",");
                json.append("\"severity\":\"").append(severity).append("\",");
                json.append("\"tumorType\":\"").append(escapeJson(tumorType)).append("\",");
                json.append("\"recommendation\":\"").append(escapeJson(recommendation)).append("\",");
                json.append("\"notes\":\"").append(escapeJson(notes)).append("\"");
                json.append("}");

                response.getWriter().write(json.toString());
            } finally {
                ps.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Database error\"}");
        } finally {
            DBConnection.closeConnection(conn);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Unauthorized\"}");
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            String role = (String) session.getAttribute("role");
            Integer userId = (Integer) session.getAttribute("userId");

            String sql = "SELECT pr.*, p.name AS patient_name, mi.file_name " +
                         "FROM PREDICTION_RESULT pr " +
                         "JOIN PATIENT p ON pr.patient_id = p.patient_id " +
                         "JOIN MEDICAL_IMAGE mi ON pr.image_id = mi.image_id ";

            if ("patient".equalsIgnoreCase(role)) {
                sql += "WHERE p.user_id = ? ";
            }

            sql += "ORDER BY pr.created_at DESC";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            if ("patient".equalsIgnoreCase(role)) {
                ps.setInt(1, userId);
            }
            ResultSet rs = null;
            try {
                rs = ps.executeQuery();

                StringBuilder json = new StringBuilder("[");
                boolean first = true;
                while (rs.next()) {
                    if (!first) json.append(",");
                    first = false;
                    json.append("{");
                    json.append("\"predictionId\":").append(rs.getInt("prediction_id")).append(",");
                    json.append("\"imageId\":").append(rs.getInt("image_id")).append(",");
                    json.append("\"patientId\":").append(rs.getInt("patient_id")).append(",");
                    json.append("\"patientName\":\"").append(escapeJson(rs.getString("patient_name"))).append("\",");
                    json.append("\"fileName\":\"").append(escapeJson(rs.getString("file_name"))).append("\",");
                    json.append("\"score\":").append(rs.getDouble("score")).append(",");
                    json.append("\"severity\":\"").append(escapeJson(rs.getString("severity"))).append("\",");
                    json.append("\"tumorType\":\"").append(escapeJson(rs.getString("tumor_type"))).append("\",");
                    json.append("\"recommendation\":\"").append(escapeJson(rs.getString("recommendation"))).append("\",");
                    json.append("\"notes\":\"").append(escapeJson(rs.getString("notes"))).append("\",");
                    json.append("\"createdAt\":\"").append(rs.getTimestamp("created_at")).append("\"");
                    json.append("}");
                }
                json.append("]");

                response.getWriter().write(json.toString());
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
                ps.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Database error\"}");
        } finally {
            DBConnection.closeConnection(conn);
        }
    }

    private void logAccess(Connection conn, int userId, String action, String ip) {
        try {
            String sql = "INSERT INTO ACCESS_LOG (user_id, action, ip_address) VALUES (?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, action);
            ps.setString(3, ip);
            ps.executeUpdate();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}
