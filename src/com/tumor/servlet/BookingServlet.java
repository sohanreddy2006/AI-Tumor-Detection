package com.tumor.servlet;

import com.tumor.util.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

/**
 * Handles appointment bookings for patients.
 * POST /booking — Creates a new appointment.
 * GET  /booking — Returns list of appointments for the logged-in user.
 */
public class BookingServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String doctorName = request.getParameter("doctorName");
        String appDate = request.getParameter("appDate"); // Expected: yyyy-MM-ddTHH:mm
        String reason = request.getParameter("reason");

        if (doctorName == null || appDate == null || doctorName.isEmpty() || appDate.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\":false, \"error\":\"Doctor name and date required.\"}");
            return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            String sql = "INSERT INTO APPOINTMENT (user_id, doctor_name, app_date, reason) VALUES (?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, doctorName);
            ps.setTimestamp(3, Timestamp.valueOf(appDate.replace("T", " ") + ":00"));
            ps.setString(4, reason);
            ps.executeUpdate();
            ps.close();

            response.setContentType("application/json");
            response.getWriter().write("{\"success\":true}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false, \"error\":\"" + e.getMessage() + "\"}");
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
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT * FROM APPOINTMENT WHERE user_id = ? ORDER BY app_date DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            StringBuilder json = new StringBuilder("[");
            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(",");
                first = false;
                json.append("{");
                json.append("\"id\":").append(rs.getInt("appointment_id")).append(",");
                json.append("\"doctorName\":\"").append(escapeJson(rs.getString("doctor_name"))).append("\",");
                json.append("\"appDate\":\"").append(rs.getTimestamp("app_date")).append("\",");
                json.append("\"reason\":\"").append(escapeJson(rs.getString("reason"))).append("\",");
                json.append("\"status\":\"").append(rs.getString("status")).append("\"");
                json.append("}");
            }
            json.append("]");
            response.getWriter().write(json.toString());
            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        } finally {
            DBConnection.closeConnection(conn);
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}
