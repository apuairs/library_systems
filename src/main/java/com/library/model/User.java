// model/User.java
package com.library.model;

import java.util.Date;

public class User {
    private Integer id;
    private String username;
    private String password;
    private String name;
    private String phone;
    private String email;
    private Integer role;      // 0-普通用户, 1-管理员
    private Integer status;    // 0-冻结, 1-正常, 2-待审核
    private Integer violationCount;
    private Date frozenUntil;
    private Date createTime;
    private Date updateTime;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public Integer getRole() { return role; }
    public void setRole(Integer role) { this.role = role; }
    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }
    public Integer getViolationCount() { return violationCount; }
    public void setViolationCount(Integer violationCount) { this.violationCount = violationCount; }
    public Date getFrozenUntil() { return frozenUntil; }
    public void setFrozenUntil(Date frozenUntil) { this.frozenUntil = frozenUntil; }
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }
    public Date getUpdateTime() { return updateTime; }
    public void setUpdateTime(Date updateTime) { this.updateTime = updateTime; }
    
    public boolean isFrozen() {
        if (frozenUntil == null) return false;
        return frozenUntil.after(new Date());
    }
    
    public String getStatusText() {
        if (status == 0) return "冻结";
        if (status == 1) return "正常";
        if (status == 2) return "待审核";
        return "未知";
    }
    
    public String getRoleText() {
        return role == 1 ? "管理员" : "普通用户";
    }
}