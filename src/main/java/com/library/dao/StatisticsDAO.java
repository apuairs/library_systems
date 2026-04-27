package com.library.dao;

import com.library.model.Statistics;
import com.library.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StatisticsDAO {
    
    public int getTodayBorrowCount() {
        String sql = "SELECT COUNT(*) FROM borrow_record WHERE DATE(borrow_time) = CURDATE()";
        return getCount(sql);
    }
    
    public int getTodayReturnCount() {
        String sql = "SELECT COUNT(*) FROM borrow_record WHERE DATE(return_time) = CURDATE()";
        return getCount(sql);
    }
    
    public int getOverdueCount() {
        String sql = "SELECT COUNT(*) FROM borrow_record WHERE status != 1 AND due_time < NOW()";
        return getCount(sql);
    }
    
    public int getTodayNewUserCount() {
        String sql = "SELECT COUNT(*) FROM user WHERE DATE(create_time) = CURDATE()";
        return getCount(sql);
    }
    
    public int getTotalUserCount() {
        String sql = "SELECT COUNT(*) FROM user WHERE role = 0";
        return getCount(sql);
    }
    
    public int getTotalBookCount() {
        String sql = "SELECT COUNT(*) FROM book WHERE status = 1";
        return getCount(sql);
    }
    
    public int getTotalBorrowCount() {
        String sql = "SELECT COUNT(*) FROM borrow_record";
        return getCount(sql);
    }
    
    public double getTotalFineAmount() {
        String sql = "SELECT SUM(fine_amount) FROM borrow_record WHERE fine_amount > 0";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return 0;
    }
    
    public double getTodayFineAmount() {
        String sql = "SELECT SUM(fine_amount) FROM borrow_record WHERE DATE(return_time) = CURDATE()";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return 0;
    }
    
    public double getSeatUsageRate(String date) {
        String sql = "SELECT COUNT(DISTINCT seat_id) FROM seat_reservation " +
                     "WHERE reserve_date = ? AND status IN (0, 1)";
        int reservedCount = getCountWithParam(sql, date);
        int totalSeats = getCount("SELECT COUNT(*) FROM seat WHERE status = 1");
        if (totalSeats == 0) return 0;
        return (double) reservedCount / totalSeats;
    }
    
    public List<Statistics> getBorrowTrend(int days) {
        String sql = "SELECT DATE(borrow_time) as date, COUNT(*) as count " +
                     "FROM borrow_record " +
                     "WHERE borrow_time >= DATE_SUB(CURDATE(), INTERVAL ? DAY) " +
                     "GROUP BY DATE(borrow_time) " +
                     "ORDER BY date";
        List<Statistics> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, days);
            rs = ps.executeQuery();
            while (rs.next()) {
                Statistics s = new Statistics();
                s.setDate(rs.getString("date"));
                s.setBorrowCount(rs.getInt("count"));
                list.add(s);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }
    
    public List<Statistics> getCategoryBorrowStats() {
        String sql = "SELECT c.name as category_name, COUNT(br.id) as borrow_count " +
                     "FROM book_category c " +
                     "LEFT JOIN book b ON c.id = b.category_id " +
                     "LEFT JOIN borrow_record br ON b.id = br.book_id " +
                     "GROUP BY c.id " +
                     "ORDER BY borrow_count DESC LIMIT 10";
        List<Statistics> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                Statistics s = new Statistics();
                s.setDate(rs.getString("category_name"));
                s.setBorrowCount(rs.getInt("borrow_count"));
                list.add(s);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }
    
    public List<Statistics> getHotBooks(int limit) {
        String sql = "SELECT b.title, COUNT(br.id) as borrow_count " +
                     "FROM book b " +
                     "LEFT JOIN borrow_record br ON b.id = br.book_id " +
                     "GROUP BY b.id " +
                     "ORDER BY borrow_count DESC LIMIT ?";
        List<Statistics> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();
            while (rs.next()) {
                Statistics s = new Statistics();
                s.setDate(rs.getString("title"));
                s.setBorrowCount(rs.getInt("borrow_count"));
                list.add(s);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }
    
    private int getCount(String sql) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
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
    
    private int getCountWithParam(String sql, Object param) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setObject(1, param);
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
}