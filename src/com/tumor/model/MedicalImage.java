package com.tumor.model;

import java.sql.Timestamp;

/**
 * Model class representing medical image metadata.
 */
public class MedicalImage {
    private int imageId;
    private int patientId;
    private String fileName;
    private String fileType;
    private String fileSize;
    private String scanType;
    private Timestamp uploadDate;

    // ── Constructors ──────────────────────────────────────────
    public MedicalImage() {}

    public MedicalImage(int patientId, String fileName, String fileType, String fileSize, String scanType) {
        this.patientId = patientId;
        this.fileName  = fileName;
        this.fileType  = fileType;
        this.fileSize  = fileSize;
        this.scanType  = scanType;
    }

    // ── Getters & Setters ─────────────────────────────────────
    public int getImageId()                { return imageId; }
    public void setImageId(int imageId)    { this.imageId = imageId; }

    public int getPatientId()                  { return patientId; }
    public void setPatientId(int patientId)    { this.patientId = patientId; }

    public String getFileName()                { return fileName; }
    public void setFileName(String fileName)   { this.fileName = fileName; }

    public String getFileType()                { return fileType; }
    public void setFileType(String fileType)   { this.fileType = fileType; }

    public String getFileSize()                { return fileSize; }
    public void setFileSize(String fileSize)   { this.fileSize = fileSize; }

    public String getScanType()                { return scanType; }
    public void setScanType(String scanType)   { this.scanType = scanType; }

    public Timestamp getUploadDate()                   { return uploadDate; }
    public void setUploadDate(Timestamp uploadDate)    { this.uploadDate = uploadDate; }
}
