// servlet/LoginServlet.java
package com.library.servlet;

import com.library.model.User;
import com.library.service.UserService;
import com.library.util.ValidateCodeUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    
    private UserService userService = new UserService();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String captcha = req.getParameter("captcha");
        
        HttpSession session = req.getSession();
        String sessionCaptcha = (String) session.getAttribute("captcha");
        
        if (captcha == null || !captcha.equalsIgnoreCase(sessionCaptcha)) {
            req.setAttribute("error", "验证码错误");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }
        
        try {
            User user = userService.login(username, password);
            if (user != null) {
                session.setAttribute("user", user);
                
                // 记录登录日志
                log(user, "登录系统", req);
                
                if (user.getRole() == 1) {
                    resp.sendRedirect(req.getContextPath() + "/admin/index.jsp");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/user/index.jsp");
                }
            } else {
                req.setAttribute("error", "用户名或密码错误");
                req.getRequestDispatcher("/login.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }
    
    private void log(User user, String operation, HttpServletRequest req) {
        // 在实际项目中，这里应该写入日志表
        System.out.println("用户[" + user.getUsername() + "] " + operation + 
                " IP: " + req.getRemoteAddr());
    }
}