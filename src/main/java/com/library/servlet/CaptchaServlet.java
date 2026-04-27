// servlet/CaptchaServlet.java
package com.library.servlet;

import com.library.util.ValidateCodeUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/captcha")
public class CaptchaServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        String code = ValidateCodeUtil.generateCode();
        
        HttpSession session = req.getSession();
        session.setAttribute("captcha", code);
        
        resp.setContentType("image/jpeg");
        resp.setHeader("Pragma", "no-cache");
        resp.setHeader("Cache-Control", "no-cache");
        resp.setDateHeader("Expires", 0);
        
        ValidateCodeUtil.outputImage(code, resp.getOutputStream());
    }
}