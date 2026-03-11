package com.tumor.servlet;

import com.tumor.util.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

/**
 * Handles patient CRUD operations.
 * GET  /patients — returns all patients as JSON.
 * POST /patients — inserts a new patient record.
 */
public class PatientServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Session check ─────────────────────────────────────
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
            String sql = "SELECT * FROM PATIENT ORDER BY created_at DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = null;
            try {
                rs = ps.executeQuery();

                StringBuilder json = new StringBuilder("[");
                boolean first = true;
                while (rs.next()) {
                    if (!first) json.append(",");
                    first = false;
                    json.append("{");
                    json.append("\"patientId\":").append(rs.getInt("patient_id")).append(",");
                    json.append("\"name\":\"").append(escapeJson(rs.getString("name"))).append("\",");
                    json.append("\"age\":").append(rs.getInt("age")).append(",");
                    json.append("\"gender\":\"").append(escapeJson(rs.getString("gender"))).append("\",");
                    json.append("\"medicalHistory\":\"").append(escapeJson(rs.getString("medical_history"))).append("\",");
                    json.append("\"contact\":\"").append(escapeJson(rs.getString("contact"))).append("\",");
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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Session check ─────────────────────────────────────
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Unauthorized\"}");
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String name    = request.getParameter("name");
        String ageStr  = request.getParameter("age");
        String gender  = request.getParameter("gender");
        String history = request.getParameter("medicalHistory");
        String contact = request.getParameter("contact");

        // ── Validation ────────────────────────────────────────
        if (name == null || name.trim().isEmpty() ||
            ageStr == null || gender == null || gender.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Name, age, and gender are required.\"}");
            return;
        }

        int age;
        try {
            age = Integer.parseInt(ageStr.trim());
            if (age < 0 || age > 150) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Invalid age value.\"}");
            return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            String sql = "INSERT INTO PATIENT (name, age, gender, medical_history, contact) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            try {
                ps.setString(1, name.trim());
                ps.setInt(2, age);
                ps.setString(3, gender.trim());
                ps.setString(4, history != null ? history.trim() : "");
                ps.setString(5, contact != null ? contact.trim() : "");
                ps.executeUpdate();

                ResultSet keys = ps.getGeneratedKeys();
                int patientId = 0;
                try {
                    if (keys.next()) {
                        patientId = keys.getInt(1);
                    }
                } finally {
                    keys.close();
                }

                // Log the activity
                logAccess(conn, (Integer) session.getAttribute("userId"), "ADD_PATIENT", request.getRemoteAddr());

                response.getWriter().write("{\"success\":true,\"patientId\":" + patientId + "}");
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
