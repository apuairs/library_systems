// servlet/SeatReserveServlet.java
package com.library.servlet;

import com.library.model.User;
import com.library.service.SeatService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/seatReserve")
public class SeatReserveServlet extends HttpServlet {
    
    private SeatService seatService = new SeatService();
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        Integer seatId = Integer.parseInt(req.getParameter("seatId"));
        String date = req.getParameter("date");
        String startTime = req.getParameter("startTime");
        String endTime = req.getParameter("endTime");
        
        try {
            boolean success = seatService.reserveSeat(user.getId(), seatId, date, startTime, endTime);
            if (success) {
                resp.sendRedirect(req.getContextPath() + "/user/mySeats.jsp");
            } else {
                req.setAttribute("error", "预约失败");
                req.getRequestDispatcher("/user/seat.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/user/seat.jsp").forward(req, resp);
        }
    }
}