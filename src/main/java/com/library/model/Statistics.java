package com.library.model;

public class Statistics {
    private String date;
    private Integer borrowCount;
    private Integer returnCount;
    private Integer newUserCount;
    private Double fineAmount;
    private Double seatUsageRate;

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }
    public Integer getBorrowCount() { return borrowCount; }
    public void setBorrowCount(Integer borrowCount) { this.borrowCount = borrowCount; }
    public Integer getReturnCount() { return returnCount; }
    public void setReturnCount(Integer returnCount) { this.returnCount = returnCount; }
    public Integer getNewUserCount() { return newUserCount; }
    public void setNewUserCount(Integer newUserCount) { this.newUserCount = newUserCount; }
    public Double getFineAmount() { return fineAmount; }
    public void setFineAmount(Double fineAmount) { this.fineAmount = fineAmount; }
    public Double getSeatUsageRate() { return seatUsageRate; }
    public void setSeatUsageRate(Double seatUsageRate) { this.seatUsageRate = seatUsageRate; }
}