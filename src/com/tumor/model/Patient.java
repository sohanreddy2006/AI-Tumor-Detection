package com.tumor.model;

import java.sql.Timestamp;

/**
 * Model class representing a patient record.
 */
public class Patient {
    private int patientId;
    private String name;
    private int age;
    private String gender;
    private String medicalHistory;
    private String contact;
    private Timestamp createdAt;

    // ── Constructors ──────────────────────────────────────────
    public Patient() {}

    public Patient(String name, int age, String gender, String medicalHistory, String contact) {
        this.name           = name;
        this.age            = age;
        this.gender         = gender;
        this.medicalHistory = medicalHistory;
        this.contact        = contact;
    }

    // ── Getters & Setters ─────────────────────────────────────
    public int getPatientId()                  { return patientId; }
    public void setPatientId(int patientId)    { this.patientId = patientId; }

    public String getName()                    { return name; }
    public void setName(String name)           { this.name = name; }

    public int getAge()                        { return age; }
    public void setAge(int age)                { this.age = age; }

    public String getGender()                  { return gender; }
    public void setGender(String gender)       { this.gender = gender; }

    public String getMedicalHistory()                       { return medicalHistory; }
    public void setMedicalHistory(String medicalHistory)    { this.medicalHistory = medicalHistory; }

    public String getContact()                 { return contact; }
    public void setContact(String contact)     { this.contact = contact; }

    public Timestamp getCreatedAt()                  { return createdAt; }
    public void setCreatedAt(Timestamp createdAt)    { this.createdAt = createdAt; }
}
