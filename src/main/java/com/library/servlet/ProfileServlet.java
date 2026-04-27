// servlet/ProfileServlet.java
package com.library.servlet;

import com.library.model.User;
import com.library.service.UserService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {
    
    private UserService userService = new UserService();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        String action = req.getParameter("action");
        
        if ("info".equals(action)) {
            req.getRequestDispatcher("/user/profile_info.jsp").forward(req, resp);
        } else if ("password".equals(action)) {
            req.getRequestDispatcher("/user/profile_password.jsp").forward(req, resp);
        } else if ("violations".equals(action)) {
            req.setAttribute("violations", userService.getViolations(user.getId()));
            req.getRequestDispatcher("/user/profile_violations.jsp").forward(req, resp);
        } else {
            req.getRequestDispatcher("/user/profile_info.jsp").forward(req, resp);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        HttpSession session = req.getSession();
        User sessionUser = (User) session.getAttribute("user");
        
        if (sessionUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        String action = req.getParameter("action");
        
        if ("updateInfo".equals(action)) {
            String name = req.getParameter("name");
            String phone = req.getParameter("phone");
            String email = req.getParameter("email");
            
            sessionUser.setName(name);
            sessionUser.setPhone(phone);
            sessionUser.setEmail(email);
            
            try {
                userService.updateProfile(sessionUser);
                session.setAttribute("user", sessionUser);
                req.setAttribute("message", "个人信息更新成功");
            } catch (Exception e) {
                req.setAttribute("error", e.getMessage());
            }
            req.getRequestDispatcher("/user/profile_info.jsp").forward(req, resp);
            
        } else if ("changePassword".equals(action)) {
            String oldPassword = req.getParameter("oldPassword");
            String newPassword = req.getParameter("newPassword");
            String confirmPassword = req.getParameter("confirmPassword");
            
            if (!newPassword.equals(confirmPassword)) {
                req.setAttribute("error", "两次输入的新密码不一致");
                req.getRequestDispatcher("/user/profile_password.jsp").forward(req, resp);
                return;
            }
            
            try {
                userService.changePassword(sessionUser.getId(), oldPassword, newPassword);
                req.setAttribute("message", "密码修改成功，请重新登录");
                session.invalidate();
                req.getRequestDispatcher("/login.jsp").forward(req, resp);
            } catch (Exception e) {
                req.setAttribute("error", e.getMessage());
                req.getRequestDispatcher("/user/profile_password.jsp").forward(req, resp);
            }
        }
    }
}