package com.tumor.servlet;

import com.tumor.util.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

/**
 * Returns recent access logs.
 * GET /logs — returns logs as JSON (admin-accessible).
 */
public class AccessLogServlet extends HttpServlet {

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
            String sql = "SELECT al.*, u.username, u.full_name FROM ACCESS_LOG al " +
                         "JOIN `USER` u ON al.user_id = u.user_id " +
                         "ORDER BY al.log_time DESC LIMIT 50";
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
                    json.append("\"logId\":").append(rs.getInt("log_id")).append(",");
                    json.append("\"userId\":").append(rs.getInt("user_id")).append(",");
                    json.append("\"username\":\"").append(escapeJson(rs.getString("username"))).append("\",");
                    json.append("\"fullName\":\"").append(escapeJson(rs.getString("full_name"))).append("\",");
                    json.append("\"action\":\"").append(escapeJson(rs.getString("action"))).append("\",");
                    json.append("\"ipAddress\":\"").append(escapeJson(rs.getString("ip_address"))).append("\",");
                    json.append("\"logTime\":\"").append(rs.getTimestamp("log_time")).append("\"");
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

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}
