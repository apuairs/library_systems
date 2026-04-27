package com.library.model;

import java.util.Date;

public class Reservation {
    private Integer id;
    private Integer userId;
    private String userName;
    private Integer bookId;
    private String bookTitle;
    private Date reserveTime;
    private Date expireTime;
    private Integer status;     // 0-预约中, 1-已取消, 2-已取书, 3-已过期
    private Date notifyTime;

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
    public Date getReserveTime() { return reserveTime; }
    public void setReserveTime(Date reserveTime) { this.reserveTime = reserveTime; }
    public Date getExpireTime() { return expireTime; }
    public void setExpireTime(Date expireTime) { this.expireTime = expireTime; }
    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }
    public Date getNotifyTime() { return notifyTime; }
    public void setNotifyTime(Date notifyTime) { this.notifyTime = notifyTime; }
    
    public String getStatusText() {
        if (status == 0) return "预约中";
        if (status == 1) return "已取消";
        if (status == 2) return "已取书";
        if (status == 3) return "已过期";
        return "未知";
    }
    
    public boolean isExpired() {
        return new Date().after(expireTime);
    }
}