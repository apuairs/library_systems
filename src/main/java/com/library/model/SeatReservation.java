package com.library.model;

import java.util.Date;

public class SeatReservation {
    private Integer id;
    private Integer userId;
    private String userName;
    private Integer seatId;
    private String seatNumber;
    private String area;
    private String reserveDate;
    private String startTime;
    private String endTime;
    private Date reserveTime;
    private Date checkinTime;
    private Date checkoutTime;
    private Integer status;    // 0-已预约, 1-已签到, 2-已签退, 3-已取消, 4-爽约
    private Boolean violationRecord;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
    public Integer getSeatId() { return seatId; }
    public void setSeatId(Integer seatId) { this.seatId = seatId; }
    public String getSeatNumber() { return seatNumber; }
    public void setSeatNumber(String seatNumber) { this.seatNumber = seatNumber; }
    public String getArea() { return area; }
    public void setArea(String area) { this.area = area; }
    public String getReserveDate() { return reserveDate; }
    public void setReserveDate(String reserveDate) { this.reserveDate = reserveDate; }
    public String getStartTime() { return startTime; }
    public void setStartTime(String startTime) { this.startTime = startTime; }
    public String getEndTime() { return endTime; }
    public void setEndTime(String endTime) { this.endTime = endTime; }
    public Date getReserveTime() { return reserveTime; }
    public void setReserveTime(Date reserveTime) { this.reserveTime = reserveTime; }
    public Date getCheckinTime() { return checkinTime; }
    public void setCheckinTime(Date checkinTime) { this.checkinTime = checkinTime; }
    public Date getCheckoutTime() { return checkoutTime; }
    public void setCheckoutTime(Date checkoutTime) { this.checkoutTime = checkoutTime; }
    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }
    public Boolean getViolationRecord() { return violationRecord; }
    public void setViolationRecord(Boolean violationRecord) { this.violationRecord = violationRecord; }
    
    public String getStatusText() {
        if (status == 0) return "已预约";
        if (status == 1) return "已签到";
        if (status == 2) return "已签退";
        if (status == 3) return "已取消";
        if (status == 4) return "爽约";
        return "未知";
    }
}