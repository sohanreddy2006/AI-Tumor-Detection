package com.tumor.servlet;

import com.tumor.util.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

/**
 * Handles medical image metadata uploads.
 * GET  /upload — returns images as JSON.
 * POST /upload — stores image metadata linked to a patient.
 */
public class ImageUploadServlet extends HttpServlet {

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
            String sql = "SELECT mi.*, p.name AS patient_name FROM MEDICAL_IMAGE mi " +
                         "JOIN PATIENT p ON mi.patient_id = p.patient_id ORDER BY mi.upload_date DESC";
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
                    json.append("\"imageId\":").append(rs.getInt("image_id")).append(",");
                    json.append("\"patientId\":").append(rs.getInt("patient_id")).append(",");
                    json.append("\"patientName\":\"").append(escapeJson(rs.getString("patient_name"))).append("\",");
                    json.append("\"fileName\":\"").append(escapeJson(rs.getString("file_name"))).append("\",");
                    json.append("\"fileType\":\"").append(escapeJson(rs.getString("file_type"))).append("\",");
                    json.append("\"fileSize\":\"").append(escapeJson(rs.getString("file_size"))).append("\",");
                    json.append("\"scanType\":\"").append(escapeJson(rs.getString("scan_type"))).append("\",");
                    json.append("\"uploadDate\":\"").append(rs.getTimestamp("upload_date")).append("\"");
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

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Unauthorized\"}");
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String patientIdStr = request.getParameter("patientId");
        String fileName     = request.getParameter("fileName");
        String fileType     = request.getParameter("fileType");
        String fileSize     = request.getParameter("fileSize");
        String scanType     = request.getParameter("scanType");

        // ── Validation ────────────────────────────────────────
        if (patientIdStr == null || fileName == null || fileName.trim().isEmpty() ||
            fileType == null || fileType.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Patient ID, file name, and file type are required.\"}");
            return;
        }

        int patientId;
        try {
            patientId = Integer.parseInt(patientIdStr.trim());
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Invalid patient ID.\"}");
            return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            String sql = "INSERT INTO MEDICAL_IMAGE (patient_id, file_name, file_type, file_size, scan_type) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            try {
                ps.setInt(1, patientId);
                ps.setString(2, fileName.trim());
                ps.setString(3, fileType.trim());
                ps.setString(4, fileSize != null ? fileSize.trim() : "Unknown");
                ps.setString(5, scanType != null ? scanType.trim() : "MRI");
                ps.executeUpdate();

                ResultSet keys = ps.getGeneratedKeys();
                int imageId = 0;
                try {
                    if (keys.next()) {
                        imageId = keys.getInt(1);
                    }
                } finally {
                    keys.close();
                }

                // Log the activity
                logAccess(conn, (Integer) session.getAttribute("userId"), "UPLOAD_IMAGE", request.getRemoteAddr());

                response.getWriter().write("{\"success\":true,\"imageId\":" + imageId + "}");
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
