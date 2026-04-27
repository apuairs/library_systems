// servlet/ReserveBookServlet.java
package com.library.servlet;

import com.library.model.User;
import com.library.service.BorrowService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/reserveBook")
public class ReserveBookServlet extends HttpServlet {
    
    private BorrowService borrowService = new BorrowService();
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        Integer bookId = Integer.parseInt(req.getParameter("bookId"));
        
        try {
            boolean success = borrowService.reserveBook(user.getId(), bookId);
            if (success) {
                resp.sendRedirect(req.getContextPath() + "/user/reservations.jsp");
            } else {
                req.setAttribute("error", "预约失败");
                req.getRequestDispatcher("/user/book_detail.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/user/book_detail.jsp").forward(req, resp);
        }
    }
}