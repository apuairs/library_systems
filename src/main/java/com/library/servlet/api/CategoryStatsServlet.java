package com.library.servlet.api;

import com.library.model.Statistics;
import com.library.service.StatisticsService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/api/categoryStats")
public class CategoryStatsServlet extends HttpServlet {
    
    private StatisticsService statsService = new StatisticsService();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=utf-8");
        
        List<Statistics> categoryStats = statsService.getCategoryBorrowStats();
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < categoryStats.size(); i++) {
            Statistics s = categoryStats.get(i);
            json.append("{\"date\":\"").append(s.getDate() != null ? s.getDate() : "未知").append("\",")
                .append("\"borrowCount\":").append(s.getBorrowCount()).append("}");
            if (i < categoryStats.size() - 1) {
                json.append(",");
            }
        }
        json.append("]");
        resp.getWriter().write(json.toString());
    }
}
