// service/UserService.java
package com.library.service;

import com.library.dao.UserDAO;
import com.library.model.User;
import com.library.model.Violation;
import com.library.util.MD5Util;

import java.util.Calendar;
import java.util.Date;
import java.util.List;

public class UserService {
    private UserDAO userDAO = new UserDAO();
    
    public User login(String username, String password) {
        System.out.println("=== 登录调试 ===");
        System.out.println("输入用户名: " + username);
        System.out.println("输入密码: " + password);
        System.out.println("输入密码MD5: " + MD5Util.encrypt(password));
        
        User user = userDAO.findByUsername(username);
        if (user != null) {
            System.out.println("找到用户: " + user.getUsername());
            System.out.println("数据库密码MD5: " + user.getPassword());
            System.out.println("用户状态: " + user.getStatus());
            System.out.println("密码匹配: " + user.getPassword().equals(MD5Util.encrypt(password)));
        } else {
            System.out.println("未找到用户: " + username);
        }
        System.out.println("=== 结束 ===");
        if (user != null && user.getPassword().equals(MD5Util.encrypt(password))) {
            if (user.getStatus() == 0) {
                if (user.isFrozen()) {
                    throw new RuntimeException("账号已被冻结至" + user.getFrozenUntil());
                } else {
                    user.setStatus(1);
                    userDAO.update(user);
                }
            }
            if (user.getStatus() == 2) {
                throw new RuntimeException("账号正在审核中，请等待审核通过");
            }
            return user;
        }
        return null;
    }
    
    public boolean register(User user) {
        User existing = userDAO.findByUsername(user.getUsername());
        if (existing != null) {
            throw new RuntimeException("用户名已存在");
        }
        user.setPassword(MD5Util.encrypt(user.getPassword()));
        user.setRole(0);
        user.setStatus(1);
        user.setViolationCount(0);
        return userDAO.insert(user) > 0;
    }
    
    public boolean changePassword(Integer userId, String oldPassword, String newPassword) {
        User user = userDAO.findById(userId);
        if (user == null || !user.getPassword().equals(MD5Util.encrypt(oldPassword))) {
            throw new RuntimeException("原密码错误");
        }
        return userDAO.updatePassword(userId, MD5Util.encrypt(newPassword)) > 0;
    }
    
    public boolean updateProfile(User user) {
        return userDAO.update(user) > 0;
    }
    
    public User getUserById(Integer id) {
        return userDAO.findById(id);
    }
    
    public List<Violation> getViolations(Integer userId) {
        return userDAO.findViolationsByUserId(userId);
    }
    
    public boolean freezeUser(Integer userId, Integer days, String reason, Integer operatorId) {
        User user = userDAO.findById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DAY_OF_MONTH, days);
        user.setFrozenUntil(cal.getTime());
        user.setStatus(0);
        
        Violation violation = new Violation();
        violation.setUserId(userId);
        violation.setType(3);
        violation.setReason(reason);
        violation.setHandleStatus(1);
        violation.setHandleBy(operatorId);
        
        boolean updated = userDAO.update(user) > 0;
        boolean violationInserted = userDAO.insertViolation(violation) > 0;
        return updated && violationInserted;
    }
    
    public boolean unfreezeUser(Integer userId) {
        User user = userDAO.findById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        user.setStatus(1);
        user.setFrozenUntil(null);
        return userDAO.update(user) > 0;
    }
    
    public List<User> getAllUsers() {
        return userDAO.findAll();
    }
    
    public List<User> getPendingUsers() {
        return userDAO.findByStatus(2);
    }
    
    public boolean approveUser(Integer userId, boolean approved) {
        User user = userDAO.findById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        user.setStatus(approved ? 1 : 0);
        return userDAO.update(user) > 0;
    }
    
    public boolean resetPassword(Integer userId) {
        String defaultPassword = MD5Util.encrypt("123456");
        return userDAO.updatePassword(userId, defaultPassword) > 0;
    }
    
    public boolean updateUserRole(Integer userId, Integer role) {
        User user = userDAO.findById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        user.setRole(role);
        return userDAO.update(user) > 0;
    }
}