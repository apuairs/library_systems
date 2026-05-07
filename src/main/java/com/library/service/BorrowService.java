// service/BorrowService.java - 简化版，确保基本功能可用
package com.library.service;

import com.library.dao.BorrowDAO;
import com.library.model.Book;
import com.library.model.BorrowRecord;
import com.library.model.Reservation;
import com.library.model.User;
import com.library.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

public class BorrowService {
    private BorrowDAO borrowDAO = new BorrowDAO();
    
    public boolean borrowBook(Integer userId, Integer bookId, Integer operatorId) {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            
            User user = borrowDAO.findUserById(userId);
            if (user == null || user.getStatus() != 1) {
                throw new RuntimeException("用户状态异常，无法借书");
            }
            
            int currentBorrowCount = borrowDAO.countBorrowingByUserId(userId);
            int maxBorrowCount = borrowDAO.getConfigValue("max_borrow_count", 10);
            if (currentBorrowCount >= maxBorrowCount) {
                throw new RuntimeException("借书数量已达上限(" + maxBorrowCount + "本)");
            }
            
            Book book = borrowDAO.findBookById(bookId);
            if (book == null || book.getStatus() != 1 || book.getAvailableCount() <= 0) {
                throw new RuntimeException("图书不可借");
            }
            
            // 先更新库存
            book.setAvailableCount(book.getAvailableCount() - 1);
            borrowDAO.updateBook(book);
            
            // 再插入借阅记录 - 使用简化的方式
            String sql = "INSERT INTO borrow_record (user_id, book_id, borrow_date, due_date, status, renew_count) " +
                         "VALUES (?, ?, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 0, 0)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, bookId);
            int result = ps.executeUpdate();
            ps.close();
            
            if (result <= 0) {
                // 回滚库存
                book.setAvailableCount(book.getAvailableCount() + 1);
                borrowDAO.updateBook(book);
                throw new RuntimeException("借阅记录插入失败");
            }
            
            return true;
            
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
    
    public boolean returnBook(Integer recordId, Integer operatorId) {
        BorrowRecord record = borrowDAO.findBorrowRecordById(recordId);
        if (record == null || record.getStatus() == 1) {
            throw new RuntimeException("借阅记录不存在或已归还");
        }
        
        record.setReturnTime(new Date());
        record.setStatus(1);
        record.setFineAmount(0.0);
        record.setOperatorId(operatorId);
        
        Book book = borrowDAO.findBookById(record.getBookId());
        book.setAvailableCount(book.getAvailableCount() + 1);
        borrowDAO.updateBook(book);
        
        return borrowDAO.updateBorrowRecord(record) > 0;
    }
    
    public boolean renewBook(Integer recordId) {
        BorrowRecord record = borrowDAO.findBorrowRecordById(recordId);
        if (record == null || record.getStatus() == 1) {
            throw new RuntimeException("借阅记录不存在或已归还");
        }
        
        int renewCount = record.getRenewCount();
        int maxRenewCount = borrowDAO.getConfigValue("max_renew_count", 2);
        if (renewCount >= maxRenewCount) {
            throw new RuntimeException("续借次数已达上限");
        }
        
        int borrowDays = borrowDAO.getConfigValue("borrow_days", 30);
        Calendar cal = Calendar.getInstance();
        cal.setTime(record.getDueTime());
        cal.add(Calendar.DAY_OF_MONTH, borrowDays);
        record.setDueTime(cal.getTime());
        record.setRenewCount(renewCount + 1);
        
        return borrowDAO.updateBorrowRecord(record) > 0;
    }
    
    public boolean reserveBook(Integer userId, Integer bookId) {
        Book book = borrowDAO.findBookById(bookId);
        if (book == null || book.getStatus() != 1) {
            throw new RuntimeException("图书不存在或不可预约");
        }
        
        if (book.getAvailableCount() > 0) {
            throw new RuntimeException("该图书目前可借，无需预约");
        }
        
        if (borrowDAO.checkBookReserved(bookId)) {
            throw new RuntimeException("该图书已被预约");
        }
        
        Reservation reservation = new Reservation();
        reservation.setUserId(userId);
        reservation.setBookId(bookId);
        reservation.setReserveTime(new Date());
        
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DAY_OF_MONTH, 3);
        reservation.setExpireTime(cal.getTime());
        reservation.setStatus(0);
        
        return borrowDAO.insertReservation(reservation) > 0;
    }
    
    public List<BorrowRecord> getCurrentBorrowing(Integer userId) {
        return borrowDAO.findCurrentBorrowingByUserId(userId);
    }
    
    public List<BorrowRecord> getBorrowHistory(Integer userId) {
        return borrowDAO.findBorrowHistoryByUserId(userId);
    }
    
    public List<BorrowRecord> getAllBorrowRecords() {
        return borrowDAO.findAllBorrowRecords();
    }
}
