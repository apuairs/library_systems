// servlet/RegisterServlet.java
package com.library.servlet;

import com.library.model.User;
import com.library.service.UserService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    
    private UserService userService = new UserService();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        req.getRequestDispatcher("/register.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");
        String name = req.getParameter("name");
        String phone = req.getParameter("phone");
        String email = req.getParameter("email");
        
        // 验证手机号格式
        if (phone != null && !phone.matches("^1[3-9]\\d{9}$")) {
            req.setAttribute("error", "手机号格式不正确");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }
        
        // 验证邮箱格式
        if (email != null && !email.matches("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")) {
            req.setAttribute("error", "邮箱格式不正确");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }
        
        if (!password.equals(confirmPassword)) {
            req.setAttribute("error", "两次输入的密码不一致");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }
        
        if (password.length() < 6) {
            req.setAttribute("error", "密码长度不能少于6位");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }
        
        User user = new User();
        user.setUsername(username);
        user.setPassword(password);
        user.setName(name);
        user.setPhone(phone);
        user.setEmail(email);
        
        try {
            boolean success = userService.register(user);
            if (success) {
                req.setAttribute("message", "注册成功，请登录");
                req.getRequestDispatcher("/login.jsp").forward(req, resp);
            } else {
                req.setAttribute("error", "注册失败");
                req.getRequestDispatcher("/register.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
        }
    }
}