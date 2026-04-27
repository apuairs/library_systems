// service/BorrowService.java
package com.library.service;

import com.library.dao.BorrowDAO;
import com.library.model.Book;
import com.library.model.BorrowRecord;
import com.library.model.Reservation;
import com.library.model.User;

import java.util.Calendar;
import java.util.Date;
import java.util.List;

public class BorrowService {
    private BorrowDAO borrowDAO = new BorrowDAO();
    
    public boolean borrowBook(Integer userId, Integer bookId, Integer operatorId) {
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
        
        BorrowRecord record = new BorrowRecord();
        record.setUserId(userId);
        record.setBookId(bookId);
        record.setBorrowTime(new Date());
        
        int borrowDays = borrowDAO.getConfigValue("borrow_days", 30);
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DAY_OF_MONTH, borrowDays);
        record.setDueTime(cal.getTime());
        record.setStatus(0);
        record.setRenewCount(0);
        record.setOperatorId(operatorId);
        
        book.setAvailableCount(book.getAvailableCount() - 1);
        borrowDAO.updateBook(book);
        
        return borrowDAO.insertBorrowRecord(record) > 0;
    }
    
    public boolean returnBook(Integer recordId, Integer operatorId) {
        BorrowRecord record = borrowDAO.findBorrowRecordById(recordId);
        if (record == null || record.getStatus() == 1) {
            throw new RuntimeException("借阅记录不存在或已归还");
        }
        
        double fine = 0;
        if (record.isOverdue()) {
            long overdueDays = record.getOverdueDays();
            double finePerDay = borrowDAO.getConfigValue("fine_per_day", 0.5);
            fine = overdueDays * finePerDay;
        }
        
        record.setReturnTime(new Date());
        record.setStatus(1);
        record.setFineAmount(fine);
        record.setOperatorId(operatorId);
        
        Book book = borrowDAO.findBookById(record.getBookId());
        book.setAvailableCount(book.getAvailableCount() + 1);
        borrowDAO.updateBook(book);
        
        if (fine > 0) {
            borrowDAO.insertViolation(record.getUserId(), 1, recordId, "逾期还书，罚款" + fine + "元");
        }
        
        return borrowDAO.updateBorrowRecord(record) > 0;
    }
    
    public boolean renewBook(Integer recordId) {
        BorrowRecord record = borrowDAO.findBorrowRecordById(recordId);
        if (record == null || record.getStatus() == 1) {
            throw new RuntimeException("借阅记录不存在或已归还");
        }
        
        int maxRenewCount = borrowDAO.getConfigValue("max_renew_count", 1);
        if (record.getRenewCount() >= maxRenewCount) {
            throw new RuntimeException("已达到最大续借次数(" + maxRenewCount + "次)");
        }
        
        if (record.isOverdue()) {
            throw new RuntimeException("图书已逾期，请先归还并缴纳罚款");
        }
        
        int borrowDays = borrowDAO.getConfigValue("borrow_days", 30);
        Calendar cal = Calendar.getInstance();
        cal.setTime(record.getDueTime());
        cal.add(Calendar.DAY_OF_MONTH, borrowDays);
        record.setDueTime(cal.getTime());
        record.setRenewCount(record.getRenewCount() + 1);
        record.setStatus(3);
        
        return borrowDAO.updateBorrowRecord(record) > 0;
    }
    
    public boolean reserveBook(Integer userId, Integer bookId) {
        boolean isReserved = borrowDAO.checkBookReserved(bookId);
        if (isReserved) {
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
    
    public List<BorrowRecord> getBorrowHistory(Integer userId) {
        return borrowDAO.findBorrowHistoryByUserId(userId);
    }
    
    public List<BorrowRecord> getCurrentBorrowing(Integer userId) {
        return borrowDAO.findCurrentBorrowingByUserId(userId);
    }
    
    public List<Reservation> getReservations(Integer userId) {
        return borrowDAO.findReservationsByUserId(userId);
    }
    
    public List<BorrowRecord> getAllBorrowRecords() {
        return borrowDAO.findAllBorrowRecords();
    }
    
    public List<BorrowRecord> getOverdueRecords() {
        return borrowDAO.findOverdueRecords();
    }
    
    public int processOverdue() {
        List<BorrowRecord> overdueRecords = borrowDAO.findOverdueRecords();
        for (BorrowRecord record : overdueRecords) {
            if (record.getStatus() != 1 && record.getStatus() != 2) {
                record.setStatus(2);
                borrowDAO.updateBorrowRecord(record);
                borrowDAO.insertViolation(record.getUserId(), 1, record.getId(), "图书逾期未还");
            }
        }
        return overdueRecords.size();
    }
    
    public BorrowRecord getBorrowRecordById(Integer id) {
        return borrowDAO.findBorrowRecordById(id);
    }
}