package com.library.model;

public class Seat {
    private Integer id;
    private Integer floor;
    private String area;
    private String seatNumber;
    private Integer status;
    private String description;
    private Boolean isReserved;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public Integer getFloor() { return floor; }
    public void setFloor(Integer floor) { this.floor = floor; }
    public String getArea() { return area; }
    public void setArea(String area) { this.area = area; }
    public String getSeatNumber() { return seatNumber; }
    public void setSeatNumber(String seatNumber) { this.seatNumber = seatNumber; }
    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Boolean getIsReserved() { return isReserved; }
    public void setIsReserved(Boolean isReserved) { this.isReserved = isReserved; }
    
    public String getStatusText() {
        return status == 1 ? "正常" : "维护中";
    }
}