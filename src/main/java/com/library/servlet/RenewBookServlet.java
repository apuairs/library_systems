// servlet/RenewBookServlet.java
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

@WebServlet("/renewBook")
public class RenewBookServlet extends HttpServlet {
    
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
        
        Integer recordId = Integer.parseInt(req.getParameter("recordId"));
        
        try {
            boolean success = borrowService.renewBook(recordId);
            if (success) {
                resp.sendRedirect(req.getContextPath() + "/user/borrowing.jsp");
            } else {
                req.setAttribute("error", "续借失败");
                req.getRequestDispatcher("/user/borrowing.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/user/borrowing.jsp").forward(req, resp);
        }
    }
}