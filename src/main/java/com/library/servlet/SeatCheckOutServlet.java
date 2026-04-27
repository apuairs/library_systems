// servlet/SeatCheckOutServlet.java
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

@WebServlet("/seatCheckOut")
public class SeatCheckOutServlet extends HttpServlet {
    
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
        
        Integer reservationId = Integer.parseInt(req.getParameter("reservationId"));
        
        try {
            boolean success = seatService.checkOut(reservationId);
            if (success) {
                resp.sendRedirect(req.getContextPath() + "/user/mySeats.jsp");
            } else {
                req.setAttribute("error", "签退失败");
                req.getRequestDispatcher("/user/mySeats.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/user/mySeats.jsp").forward(req, resp);
        }
    }
}