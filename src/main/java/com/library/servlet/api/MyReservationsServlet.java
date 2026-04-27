package com.library.servlet.api;

import com.library.service.SeatService;
import com.library.model.SeatReservation;
import com.library.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.util.List;

@WebServlet("/api/my-reservations")
public class MyReservationsServlet extends HttpServlet {
    
    private SeatService seatService = new SeatService();
    private ObjectMapper objectMapper = new ObjectMapper();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"error\": \"未登录\"}");
            return;
        }
        
        try {
            List<SeatReservation> reservations = seatService.getMyReservations(user.getId());
            
            // 构建响应数据
            java.util.Map<String, Object> response = new java.util.HashMap<>();
            response.put("reservations", reservations);
            
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            objectMapper.writeValue(resp.getOutputStream(), response);
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }
}
