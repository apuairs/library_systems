package com.library.dao;

import com.library.model.User;
import com.library.model.Violation;
import com.library.util.DBUtil;

import java.sql.*;
import java.util.List;

public class UserDAO extends BaseDAO<User> {
    
    @Override
    protected User mapRow(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setName(rs.getString("name"));
        user.setPhone(rs.getString("phone"));
        user.setEmail(rs.getString("email"));
        user.setRole(rs.getInt("role"));
        user.setStatus(rs.getInt("status"));
        user.setViolationCount(rs.getInt("violation_count"));
        user.setFrozenUntil(rs.getTimestamp("frozen_until"));
        user.setCreateTime(rs.getTimestamp("create_time"));
        user.setUpdateTime(rs.getTimestamp("update_time"));
        return user;
    }
    
    public User findById(Integer id) {
        String sql = "SELECT * FROM user WHERE id = ?";
        return queryOne(sql, id);
    }
    
    public User findByUsername(String username) {
        String sql = "SELECT * FROM user WHERE username = ?";
        return queryOne(sql, username);
    }
    
    public List<User> findAll() {
        String sql = "SELECT * FROM user ORDER BY create_time DESC";
        return query(sql);
    }
    
    public List<User> findByStatus(Integer status) {
        String sql = "SELECT * FROM user WHERE status = ? ORDER BY create_time DESC";
        return query(sql, status);
    }
    
    public int insert(User user) {
        String sql = "INSERT INTO user (username, password, name, phone, email, role, status, violation_count) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        return update(sql, user.getUsername(), user.getPassword(), user.getName(), 
                user.getPhone(), user.getEmail(), user.getRole(), user.getStatus(), user.getViolationCount());
    }
    
    public int update(User user) {
        String sql = "UPDATE user SET name=?, phone=?, email=?, status=?, violation_count=?, frozen_until=? WHERE id=?";
        return update(sql, user.getName(), user.getPhone(), user.getEmail(), 
                user.getStatus(), user.getViolationCount(), user.getFrozenUntil(), user.getId());
    }
    
    public int updatePassword(Integer userId, String password) {
        String sql = "UPDATE user SET password=? WHERE id=?";
        return update(sql, password, userId);
    }
    
    public List<Violation> findViolationsByUserId(Integer userId) {
        String sql = "SELECT v.*, u.name as user_name, h.name as handler_name " +
                     "FROM violation v " +
                     "LEFT JOIN user u ON v.user_id = u.id " +
                     "LEFT JOIN user h ON v.handle_by = h.id " +
                     "WHERE v.user_id = ? " +
                     "ORDER BY v.create_time DESC";
        return queryViolation(sql, userId);
    }
    
    public List<Violation> findAllViolations() {
        String sql = "SELECT v.*, u.name as user_name, h.name as handler_name " +
                     "FROM violation v " +
                     "LEFT JOIN user u ON v.user_id = u.id " +
                     "LEFT JOIN user h ON v.handle_by = h.id " +
                     "ORDER BY v.create_time DESC";
        return queryViolation(sql);
    }
    
    public int insertViolation(Violation violation) {
        String sql = "INSERT INTO violation (user_id, type, related_id, reason, handle_status, handle_by) VALUES (?, ?, ?, ?, ?, ?)";
        return update(sql, violation.getUserId(), violation.getType(), violation.getRelatedId(),
                violation.getReason(), violation.getHandleStatus(), violation.getHandleBy());
    }
    
    private List<Violation> queryViolation(String sql, Object... params) {
        List<Violation> list = new java.util.ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Violation v = new Violation();
                v.setId(rs.getInt("id"));
                v.setUserId(rs.getInt("user_id"));
                v.setUserName(rs.getString("user_name"));
                v.setType(rs.getInt("type"));
                v.setRelatedId(rs.getInt("related_id"));
                v.setReason(rs.getString("reason"));
                v.setCreateTime(rs.getTimestamp("create_time"));
                v.setHandleStatus(rs.getInt("handle_status"));
                v.setHandleBy(rs.getInt("handle_by"));
                v.setHandlerName(rs.getString("handler_name"));
                list.add(v);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }
}