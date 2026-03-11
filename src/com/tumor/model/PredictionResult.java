package com.tumor.model;

import java.sql.Timestamp;

/**
 * Model class representing a tumor prediction result.
 */
public class PredictionResult {
    private int predictionId;
    private int imageId;
    private int patientId;
    private double score;
    private String severity;
    private String notes;
    private Timestamp createdAt;

    // Extra fields for display (joined from other tables)
    private String patientName;
    private String fileName;

    // ── Constructors ──────────────────────────────────────────
    public PredictionResult() {}

    public PredictionResult(int imageId, int patientId, double score, String severity, String notes) {
        this.imageId   = imageId;
        this.patientId = patientId;
        this.score     = score;
        this.severity  = severity;
        this.notes     = notes;
    }

    // ── Getters & Setters ─────────────────────────────────────
    public int getPredictionId()                       { return predictionId; }
    public void setPredictionId(int predictionId)      { this.predictionId = predictionId; }

    public int getImageId()                { return imageId; }
    public void setImageId(int imageId)    { this.imageId = imageId; }

    public int getPatientId()                  { return patientId; }
    public void setPatientId(int patientId)    { this.patientId = patientId; }

    public double getScore()               { return score; }
    public void setScore(double score)     { this.score = score; }

    public String getSeverity()                    { return severity; }
    public void setSeverity(String severity)       { this.severity = severity; }

    public String getNotes()               { return notes; }
    public void setNotes(String notes)     { this.notes = notes; }

    public Timestamp getCreatedAt()                  { return createdAt; }
    public void setCreatedAt(Timestamp createdAt)    { this.createdAt = createdAt; }

    public String getPatientName()                     { return patientName; }
    public void setPatientName(String patientName)     { this.patientName = patientName; }

    public String getFileName()                { return fileName; }
    public void setFileName(String fileName)   { this.fileName = fileName; }
}
