package com.library.model;

import java.util.Date;

public class Violation {
    private Integer id;
    private Integer userId;
    private String userName;
    private Integer type;       // 1-逾期还书, 2-预约爽约, 3-座位违规
    private Integer relatedId;
    private String reason;
    private Date createTime;
    private Integer handleStatus;  // 0-未处理, 1-已处理
    private Integer handleBy;
    private String handlerName;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
    public Integer getType() { return type; }
    public void setType(Integer type) { this.type = type; }
    public Integer getRelatedId() { return relatedId; }
    public void setRelatedId(Integer relatedId) { this.relatedId = relatedId; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }
    public Integer getHandleStatus() { return handleStatus; }
    public void setHandleStatus(Integer handleStatus) { this.handleStatus = handleStatus; }
    public Integer getHandleBy() { return handleBy; }
    public void setHandleBy(Integer handleBy) { this.handleBy = handleBy; }
    public String getHandlerName() { return handlerName; }
    public void setHandlerName(String handlerName) { this.handlerName = handlerName; }
    
    public String getTypeText() {
        if (type == 1) return "逾期还书";
        if (type == 2) return "预约爽约";
        if (type == 3) return "座位违规";
        return "未知";
    }
    
    public String getHandleStatusText() {
        return handleStatus == 1 ? "已处理" : "未处理";
    }
}