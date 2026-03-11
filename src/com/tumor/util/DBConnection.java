package com.tumor.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Database connection utility for the Tumor Detection System.
 * Uses JDBC to connect to MySQL database.
 */
public class DBConnection {

    // ── Configuration ─────────────────────────────────────────
    private static final String DB_URL  = "jdbc:mysql://localhost:3306/tumor_detection_db";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "root123";   // Updated for user's MySQL setup
    private static final String DRIVER  = "com.mysql.cj.jdbc.Driver";

    // ── Get Connection ────────────────────────────────────────
    public static Connection getConnection() throws SQLException {
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found.", e);
        }
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    }

    // ── Close Connection ──────────────────────────────────────
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
