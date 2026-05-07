package com.library.dao;

import com.library.model.Book;
import com.library.model.BorrowRecord;
import com.library.model.Reservation;
import com.library.model.User;
import com.library.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BorrowDAO extends BaseDAO<BorrowRecord> {
    
    @Override
    protected BorrowRecord mapRow(ResultSet rs) throws SQLException {
        BorrowRecord record = new BorrowRecord();
        record.setId(rs.getInt("id"));
        record.setUserId(rs.getInt("user_id"));
        
        // 安全获取可选字段
        try { record.setUserName(rs.getString("user_name")); } catch (SQLException e) { /* 忽略 */ }
        try { record.setBookTitle(rs.getString("book_title")); } catch (SQLException e) { /* 忽略 */ }
        try { record.setBookIsbn(rs.getString("book_isbn")); } catch (SQLException e) { /* 忽略 */ }
        try { record.setOperatorName(rs.getString("operator_name")); } catch (SQLException e) { /* 忽略 */ }
        
        record.setBookId(rs.getInt("book_id"));
        record.setBorrowTime(rs.getTimestamp("borrow_date"));
        record.setDueTime(rs.getTimestamp("due_date"));
        
        try { record.setReturnTime(rs.getTimestamp("return_date")); } catch (SQLException e) { /* 忽略 */ }
        
        record.setStatus(rs.getInt("status"));
        record.setRenewCount(rs.getInt("renew_count"));
        
        // 安全获取可能不存在的字段
        try { record.setFineAmount(rs.getDouble("fine_amount")); } catch (SQLException e) { record.setFineAmount(0.0); }
        try { record.setOperatorId(rs.getInt("operator_id")); } catch (SQLException e) { record.setOperatorId(null); }
        
        return record;
    }
    
    public User findUserById(Integer userId) {
        String sql = "SELECT * FROM user WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setName(rs.getString("name"));
                user.setStatus(rs.getInt("status"));
                return user;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return null;
    }
    
    public Book findBookById(Integer bookId) {
        String sql = "SELECT * FROM book WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, bookId);
            rs = ps.executeQuery();
            if (rs.next()) {
                Book book = new Book();
                book.setId(rs.getInt("id"));
                book.setIsbn(rs.getString("isbn"));
                book.setTitle(rs.getString("title"));
                book.setStatus(rs.getInt("status"));
                book.setAvailableCount(rs.getInt("available_count"));
                return book;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return null;
    }
    
    public int updateBook(Book book) {
        String sql = "UPDATE book SET available_count = ? WHERE id = ?";
        return update(sql, book.getAvailableCount(), book.getId());
    }
    
    public int updateBook(Connection conn, Book book) throws SQLException {
        String sql = "UPDATE book SET available_count = ? WHERE id = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, book.getAvailableCount());
        ps.setInt(2, book.getId());
        return ps.executeUpdate();
    }
    
    public int countBorrowingByUserId(Integer userId) {
        String sql = "SELECT COUNT(*) FROM borrow_record WHERE user_id = ? AND status != 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return 0;
    }
    
    public int getConfigValue(String key, int defaultValue) {
        return defaultValue;
    }
    
    public double getConfigValue(String key, double defaultValue) {
        return defaultValue;
    }
    
    public int insertBorrowRecord(BorrowRecord record) {
        String sql = "INSERT INTO borrow_record (user_id, book_id, borrow_date, due_date, status, renew_count, operator_id) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        return update(sql, record.getUserId(), record.getBookId(), record.getBorrowTime(),
                record.getDueTime(), record.getStatus(), record.getRenewCount(), record.getOperatorId());
    }
    
    public int insertBorrowRecord(Connection conn, BorrowRecord record) throws SQLException {
        String sql = "INSERT INTO borrow_record (user_id, book_id, borrow_date, due_date, status, renew_count, operator_id) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, record.getUserId());
        ps.setInt(2, record.getBookId());
        ps.setTimestamp(3, new java.sql.Timestamp(record.getBorrowTime().getTime()));
        ps.setTimestamp(4, new java.sql.Timestamp(record.getDueTime().getTime()));
        ps.setInt(5, record.getStatus());
        ps.setInt(6, record.getRenewCount());
        ps.setInt(7, record.getOperatorId());
        return ps.executeUpdate();
    }
    
    public BorrowRecord findBorrowRecordById(Integer id) {
        String sql = "SELECT br.*, u.name as user_name, b.title as book_title, b.isbn as book_isbn " +
                     "FROM borrow_record br " +
                     "LEFT JOIN user u ON br.user_id = u.id " +
                     "LEFT JOIN book b ON br.book_id = b.id " +
                     "WHERE br.id = ?";
        return queryOne(sql, id);
    }
    
    public int updateBorrowRecord(BorrowRecord record) {
        // 简化更新，只更新核心字段，避免依赖可能不存在的字段
        String sql = "UPDATE borrow_record SET return_date=?, status=?, renew_count=? WHERE id=?";
        return update(sql, record.getReturnTime(), record.getStatus(), record.getRenewCount(), record.getId());
    }
    
    public List<BorrowRecord> findBorrowHistoryByUserId(Integer userId) {
        String sql = "SELECT br.*, u.name as user_name, b.title as book_title, b.isbn as book_isbn " +
                     "FROM borrow_record br " +
                     "LEFT JOIN user u ON br.user_id = u.id " +
                     "LEFT JOIN book b ON br.book_id = b.id " +
                     "WHERE br.user_id = ? " +
                     "ORDER BY br.borrow_date DESC";
        return query(sql, userId);
    }
    
    public List<BorrowRecord> findCurrentBorrowingByUserId(Integer userId) {
        String sql = "SELECT br.*, u.name as user_name, b.title as book_title, b.isbn as book_isbn " +
                     "FROM borrow_record br " +
                     "LEFT JOIN user u ON br.user_id = u.id " +
                     "LEFT JOIN book b ON br.book_id = b.id " +
                     "WHERE br.user_id = ? AND br.status != 1 " +
                     "ORDER BY br.due_date ASC";
        return query(sql, userId);
    }
    
    public List<BorrowRecord> findAllBorrowRecords() {
        String sql = "SELECT br.*, u.name as user_name, b.title as book_title, b.isbn as book_isbn " +
                     "FROM borrow_record br " +
                     "LEFT JOIN user u ON br.user_id = u.id " +
                     "LEFT JOIN book b ON br.book_id = b.id " +
                     "ORDER BY br.borrow_date DESC";
        return query(sql);
    }
    
    public List<BorrowRecord> findOverdueRecords() {
        String sql = "SELECT br.*, u.name as user_name, b.title as book_title, b.isbn as book_isbn " +
                     "FROM borrow_record br " +
                     "LEFT JOIN user u ON br.user_id = u.id " +
                     "LEFT JOIN book b ON br.book_id = b.id " +
                     "WHERE br.status != 1 AND br.due_date < NOW()";
        return query(sql);
    }
    
    public boolean checkBookReserved(Integer bookId) {
        String sql = "SELECT COUNT(*) FROM reservation WHERE book_id = ? AND status = 0";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, bookId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return false;
    }
    
    public int insertReservation(Reservation reservation) {
        String sql = "INSERT INTO reservation (user_id, book_id, reserve_time, expire_time, status) " +
                     "VALUES (?, ?, ?, ?, ?)";
        return update(sql, reservation.getUserId(), reservation.getBookId(), reservation.getReserveTime(),
                reservation.getExpireTime(), reservation.getStatus());
    }
    
    public List<Reservation> findReservationsByUserId(Integer userId) {
        String sql = "SELECT r.*, u.name as user_name, b.title as book_title " +
                     "FROM reservation r " +
                     "LEFT JOIN user u ON r.user_id = u.id " +
                     "LEFT JOIN book b ON r.book_id = b.id " +
                     "WHERE r.user_id = ? " +
                     "ORDER BY r.reserve_time DESC";
        List<Reservation> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) {
                Reservation r = new Reservation();
                r.setId(rs.getInt("id"));
                r.setUserId(rs.getInt("user_id"));
                r.setUserName(rs.getString("user_name"));
                r.setBookId(rs.getInt("book_id"));
                r.setBookTitle(rs.getString("book_title"));
                r.setReserveTime(rs.getTimestamp("reserve_time"));
                r.setExpireTime(rs.getTimestamp("expire_time"));
                r.setStatus(rs.getInt("status"));
                r.setNotifyTime(rs.getTimestamp("notify_time"));
                list.add(r);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }
    
    public int insertViolation(Integer userId, Integer type, Integer relatedId, String reason) {
        String sql = "INSERT INTO violation (user_id, type, related_id, reason, handle_status) VALUES (?, ?, ?, ?, 0)";
        return update(sql, userId, type, relatedId, reason);
    }
}