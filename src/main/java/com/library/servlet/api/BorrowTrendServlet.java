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

@WebServlet("/api/borrowTrend")
public class BorrowTrendServlet extends HttpServlet {
    
    private StatisticsService statsService = new StatisticsService();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=utf-8");
        
        String daysParam = req.getParameter("days");
        int days = 7;
        try {
            if (daysParam != null) {
                days = Integer.parseInt(daysParam);
            }
        } catch (NumberFormatException e) {
            // 使用默认值
        }
        
        List<Statistics> trend = statsService.getBorrowTrend(days);
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < trend.size(); i++) {
            Statistics s = trend.get(i);
            json.append("{\"date\":\"").append(s.getDate()).append("\",")
                .append("\"borrowCount\":").append(s.getBorrowCount()).append("}");
            if (i < trend.size() - 1) {
                json.append(",");
            }
        }
        json.append("]");
        resp.getWriter().write(json.toString());
    }
}
