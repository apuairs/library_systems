// service/StatisticsService.java
package com.library.service;

import com.library.dao.StatisticsDAO;
import com.library.model.Statistics;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

public class StatisticsService {
    private StatisticsDAO statisticsDAO = new StatisticsDAO();
    
    public int getTodayBorrowCount() {
        return statisticsDAO.getTodayBorrowCount();
    }
    
    public int getTodayReturnCount() {
        return statisticsDAO.getTodayReturnCount();
    }
    
    public int getOverdueCount() {
        return statisticsDAO.getOverdueCount();
    }
    
    public int getTodayNewUserCount() {
        return statisticsDAO.getTodayNewUserCount();
    }
    
    public int getTotalUserCount() {
        return statisticsDAO.getTotalUserCount();
    }
    
    public int getTotalBookCount() {
        return statisticsDAO.getTotalBookCount();
    }
    
    public int getTotalBorrowCount() {
        return statisticsDAO.getTotalBorrowCount();
    }
    
    public double getTotalFineAmount() {
        return statisticsDAO.getTotalFineAmount();
    }
    
    public double getTodayFineAmount() {
        return statisticsDAO.getTodayFineAmount();
    }
    
    public double getSeatUsageRate() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        return statisticsDAO.getSeatUsageRate(sdf.format(new Date()));
    }
    
    public List<Statistics> getBorrowTrend(int days) {
        return statisticsDAO.getBorrowTrend(days);
    }
    
    public List<Statistics> getCategoryBorrowStats() {
        return statisticsDAO.getCategoryBorrowStats();
    }
    
    public List<Statistics> getHotBooks(int limit) {
        return statisticsDAO.getHotBooks(limit);
    }
}