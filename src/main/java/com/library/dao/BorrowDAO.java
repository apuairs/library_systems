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
        record.setUserName(rs.getString("user_name"));
        record.setBookId(rs.getInt("book_id"));
        record.setBookTitle(rs.getString("book_title"));
        record.setBookIsbn(rs.getString("book_isbn"));
        record.setBorrowTime(rs.getTimestamp("borrow_time"));
        record.setDueTime(rs.getTimestamp("due_time"));
        record.setReturnTime(rs.getTimestamp("return_time"));
        record.setStatus(rs.getInt("status"));
        record.setRenewCount(rs.getInt("renew_count"));
        record.setFineAmount(rs.getDouble("fine_amount"));
        record.setOperatorId(rs.getInt("operator_id"));
        record.setOperatorName(rs.getString("operator_name"));
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
        String sql = "INSERT INTO borrow_record (user_id, book_id, borrow_time, due_time, status, renew_count, operator_id) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        return update(sql, record.getUserId(), record.getBookId(), record.getBorrowTime(),
                record.getDueTime(), record.getStatus(), record.getRenewCount(), record.getOperatorId());
    }
    
    public BorrowRecord findBorrowRecordById(Integer id) {
        String sql = "SELECT br.*, u.name as user_name, b.title as book_title, b.isbn as book_isbn, " +
                     "op.name as operator_name " +
                     "FROM borrow_record br " +
                     "LEFT JOIN user u ON br.user_id = u.id " +
                     "LEFT JOIN book b ON br.book_id = b.id " +
                     "LEFT JOIN user op ON br.operator_id = op.id " +
                     "WHERE br.id = ?";
        return queryOne(sql, id);
    }
    
    public int updateBorrowRecord(BorrowRecord record) {
        String sql = "UPDATE borrow_record SET return_time=?, status=?, renew_count=?, fine_amount=?, operator_id=? WHERE id=?";
        return update(sql, record.getReturnTime(), record.getStatus(), record.getRenewCount(),
                record.getFineAmount(), record.getOperatorId(), record.getId());
    }
    
    public List<BorrowRecord> findBorrowHistoryByUserId(Integer userId) {
        String sql = "SELECT br.*, u.name as user_name, b.title as book_title, b.isbn as book_isbn, " +
                     "op.name as operator_name " +
                     "FROM borrow_record br " +
                     "LEFT JOIN user u ON br.user_id = u.id " +
                     "LEFT JOIN book b ON br.book_id = b.id " +
                     "LEFT JOIN user op ON br.operator_id = op.id " +
                     "WHERE br.user_id = ? " +
                     "ORDER BY br.borrow_time DESC";
        return query(sql, userId);
    }
    
    public List<BorrowRecord> findCurrentBorrowingByUserId(Integer userId) {
        String sql = "SELECT br.*, u.name as user_name, b.title as book_title, b.isbn as book_isbn, " +
                     "op.name as operator_name " +
                     "FROM borrow_record br " +
                     "LEFT JOIN user u ON br.user_id = u.id " +
                     "LEFT JOIN book b ON br.book_id = b.id " +
                     "LEFT JOIN user op ON br.operator_id = op.id " +
                     "WHERE br.user_id = ? AND br.status != 1 " +
                     "ORDER BY br.due_time ASC";
        return query(sql, userId);
    }
    
    public List<BorrowRecord> findAllBorrowRecords() {
        String sql = "SELECT br.*, u.name as user_name, b.title as book_title, b.isbn as book_isbn, " +
                     "op.name as operator_name " +
                     "FROM borrow_record br " +
                     "LEFT JOIN user u ON br.user_id = u.id " +
                     "LEFT JOIN book b ON br.book_id = b.id " +
                     "LEFT JOIN user op ON br.operator_id = op.id " +
                     "ORDER BY br.borrow_time DESC";
        return query(sql);
    }
    
    public List<BorrowRecord> findOverdueRecords() {
        String sql = "SELECT br.*, u.name as user_name, b.title as book_title, b.isbn as book_isbn, " +
                     "op.name as operator_name " +
                     "FROM borrow_record br " +
                     "LEFT JOIN user u ON br.user_id = u.id " +
                     "LEFT JOIN book b ON br.book_id = b.id " +
                     "LEFT JOIN user op ON br.operator_id = op.id " +
                     "WHERE br.status != 1 AND br.due_time < NOW()";
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