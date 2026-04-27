package com.library.model;

import java.util.Date;

public class BorrowRecord {
    private Integer id;
    private Integer userId;
    private String userName;
    private Integer bookId;
    private String bookTitle;
    private String bookIsbn;
    private Date borrowTime;
    private Date dueTime;
    private Date returnTime;
    private Integer status;     // 0-借出中, 1-已归还, 2-逾期, 3-续借中
    private Integer renewCount;
    private Double fineAmount;
    private Integer operatorId;
    private String operatorName;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
    public Integer getBookId() { return bookId; }
    public void setBookId(Integer bookId) { this.bookId = bookId; }
    public String getBookTitle() { return bookTitle; }
    public void setBookTitle(String bookTitle) { this.bookTitle = bookTitle; }
    public String getBookIsbn() { return bookIsbn; }
    public void setBookIsbn(String bookIsbn) { this.bookIsbn = bookIsbn; }
    public Date getBorrowTime() { return borrowTime; }
    public void setBorrowTime(Date borrowTime) { this.borrowTime = borrowTime; }
    public Date getDueTime() { return dueTime; }
    public void setDueTime(Date dueTime) { this.dueTime = dueTime; }
    public Date getReturnTime() { return returnTime; }
    public void setReturnTime(Date returnTime) { this.returnTime = returnTime; }
    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }
    public Integer getRenewCount() { return renewCount; }
    public void setRenewCount(Integer renewCount) { this.renewCount = renewCount; }
    public Double getFineAmount() { return fineAmount; }
    public void setFineAmount(Double fineAmount) { this.fineAmount = fineAmount; }
    public Integer getOperatorId() { return operatorId; }
    public void setOperatorId(Integer operatorId) { this.operatorId = operatorId; }
    public String getOperatorName() { return operatorName; }
    public void setOperatorName(String operatorName) { this.operatorName = operatorName; }
    
    public boolean isOverdue() {
        if (status == 1) return false;
        if (dueTime == null) return false;
        return new Date().after(dueTime);
    }
    
    public long getOverdueDays() {
        if (!isOverdue()) return 0;
        long diff = new Date().getTime() - dueTime.getTime();
        return diff / (1000 * 60 * 60 * 24);
    }
    
    public String getStatusText() {
        if (status == 0) return "借出中";
        if (status == 1) return "已归还";
        if (status == 2) return "逾期";
        if (status == 3) return "续借中";
        return "未知";
    }
}