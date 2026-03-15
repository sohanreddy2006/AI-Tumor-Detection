package com.tumor.servlet;

import com.tumor.util.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

/**
 * Handles user registration.
 * POST /signup — creates a new user account if the username is unique.
 */
public class SignupServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fullName = request.getParameter("fullName");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String role     = request.getParameter("role");

        // ── Input validation ──────────────────────────────────
        if (fullName == null || fullName.trim().isEmpty() ||
            username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            role == null || role.trim().isEmpty()) {
            response.sendRedirect("index.html?error=empty");
            return;
        }

        fullName = fullName.trim();
        username = username.trim();
        password = password.trim();
        role     = role.trim();

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();

            // ── Check if username already exists ──────────────
            String checkSql = "SELECT user_id FROM `USER` WHERE username = ?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setString(1, username);
            ResultSet rs = checkPs.executeQuery();

            if (rs.next()) {
                rs.close();
                checkPs.close();
                response.sendRedirect("index.html?error=exists");
                return;
            }
            rs.close();
            checkPs.close();

            // ── Insert new user ───────────────────────────────
            String insertSql = "INSERT INTO `USER` (username, password, full_name, role) VALUES (?, ?, ?, ?)";
            PreparedStatement insertPs = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
            try {
                insertPs.setString(1, username);
                insertPs.setString(2, password);
                insertPs.setString(3, fullName);
                insertPs.setString(4, role);
                insertPs.executeUpdate();

                ResultSet keys = insertPs.getGeneratedKeys();
                if (keys.next()) {
                    int newUserId = keys.getInt(1);
                    // Log the registration as an access log entry
                    logAccess(conn, newUserId, "REGISTER", request.getRemoteAddr());

                    // If user is a patient, create a record in the PATIENT table
                    if ("patient".equalsIgnoreCase(role)) {
                        createPatientProfile(conn, newUserId, fullName);
                    }
                }
                keys.close();

                response.sendRedirect("index.html?success=registered");
            } finally {
                insertPs.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("index.html?error=server");
        } finally {
            DBConnection.closeConnection(conn);
        }
    }

    /** Creates a linked entry in the PATIENT table for new patient users. */
    private void createPatientProfile(Connection conn, int userId, String name) {
        try {
            // Default age/gender/contact for simulation purposes
            String sql = "INSERT INTO PATIENT (name, age, gender, medical_history, contact, user_id) VALUES (?, 30, 'Other', 'New User', 'None', ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            ps.setInt(2, userId);
            ps.executeUpdate();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
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
}
