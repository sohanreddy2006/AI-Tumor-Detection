package com.tumor.servlet;

import com.tumor.util.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

/**
 * Handles user authentication.
 * POST /login — verifies credentials, creates session, logs access.
 */
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // ── Input validation ──────────────────────────────────
        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            response.sendRedirect("index.html?error=empty");
            return;
        }

        username = username.trim();
        password = password.trim();

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();

            // ── Authenticate using PreparedStatement ──────────
            String sql = "SELECT user_id, username, full_name, role FROM `USER` WHERE username = ? AND password = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = null;
            try {
                ps.setString(1, username);
                ps.setString(2, password);
                rs = ps.executeQuery();

                if (rs.next()) {
                    // ── Create session ────────────────────────────
                    HttpSession session = request.getSession();
                    session.setAttribute("userId",   rs.getInt("user_id"));
                    session.setAttribute("username", rs.getString("username"));
                    session.setAttribute("fullName", rs.getString("full_name"));
                    session.setAttribute("role",     rs.getString("role"));

                    // ── Log access ────────────────────────────────
                    logAccess(conn, rs.getInt("user_id"), "LOGIN", request.getRemoteAddr());

                    response.sendRedirect("dashboard.jsp");
                } else {
                    response.sendRedirect("index.html?error=invalid");
                }
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
                ps.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("index.html?error=server");
        } finally {
            DBConnection.closeConnection(conn);
        }
    }

    /** Inserts a record into the ACCESS_LOG table. */
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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // ── Logout ────────────────────────────────────────────
        HttpSession session = request.getSession(false);
        if (session != null) {
            // Log the logout
            Connection conn = null;
            try {
                conn = DBConnection.getConnection();
                Integer userId = (Integer) session.getAttribute("userId");
                if (userId != null) {
                    logAccess(conn, userId, "LOGOUT", request.getRemoteAddr());
                }
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                DBConnection.closeConnection(conn);
            }
            session.invalidate();
        }
        response.sendRedirect("index.html");
    }
}
