// servlet/BorrowBookServlet.java
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
import java.io.PrintWriter;

@WebServlet("/borrowBook")
public class BorrowBookServlet extends HttpServlet {
    
    private BorrowService borrowService = new BorrowService();
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            out.print("{\"success\":false,\"message\":\"请先登录\"}");
            return;
        }
        
        Integer bookId = Integer.parseInt(req.getParameter("bookId"));
        
        try {
            boolean success = borrowService.borrowBook(user.getId(), bookId, user.getId());
            if (success) {
                out.print("{\"success\":true,\"message\":\"借阅成功\"}");
            } else {
                out.print("{\"success\":false,\"message\":\"借书失败\"}");
            }
        } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
        }
    }
}
