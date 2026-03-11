package com.tumor.model;

import java.sql.Timestamp;

/**
 * Model class representing a system user.
 */
public class User {
    private int userId;
    private String username;
    private String password;
    private String fullName;
    private String role;
    private Timestamp createdAt;

    // ── Constructors ──────────────────────────────────────────
    public User() {}

    public User(int userId, String username, String fullName, String role) {
        this.userId   = userId;
        this.username = username;
        this.fullName = fullName;
        this.role     = role;
    }

    // ── Getters & Setters ─────────────────────────────────────
    public int getUserId()              { return userId; }
    public void setUserId(int userId)   { this.userId = userId; }

    public String getUsername()                 { return username; }
    public void setUsername(String username)    { this.username = username; }

    public String getPassword()                { return password; }
    public void setPassword(String password)   { this.password = password; }

    public String getFullName()                { return fullName; }
    public void setFullName(String fullName)   { this.fullName = fullName; }

    public String getRole()                    { return role; }
    public void setRole(String role)           { this.role = role; }

    public Timestamp getCreatedAt()                  { return createdAt; }
    public void setCreatedAt(Timestamp createdAt)    { this.createdAt = createdAt; }
}
