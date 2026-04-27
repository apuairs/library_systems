package com.library.servlet.api;

import com.library.service.SeatService;
import com.library.model.Seat;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.util.List;

@WebServlet("/api/seats")
public class SeatsServlet extends HttpServlet {
    
    private SeatService seatService = new SeatService();
    private ObjectMapper objectMapper = new ObjectMapper();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        String date = req.getParameter("date");
        String startTime = req.getParameter("startTime");
        String endTime = req.getParameter("endTime");
        
        try {
            List<Seat> seats;
            if (date != null && !date.isEmpty()) {
                seats = seatService.getSeatStatus(date, startTime, endTime);
            } else {
                seats = seatService.getAllSeats();
            }
            
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            objectMapper.writeValue(resp.getOutputStream(), seats);
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }
}