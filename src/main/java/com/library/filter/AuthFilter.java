// filter/AuthFilter.java
package com.library.filter;

import com.library.model.User;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

@WebFilter("/*")
public class AuthFilter implements Filter {
    
    private static final List<String> PUBLIC_PATHS = Arrays.asList(
        "/login", "/login.jsp", "/register", "/register.jsp", "/logout", "/captcha", 
        "/css/", "/js/", "/images/", "/index.jsp", "/testlogin.jsp", "/fix.jsp", 
        "/resetpwd.jsp", "/_debug_db.jsp", "/_test_", "/_debug_db_structure.jsp"
    );
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        
        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();
        String path = uri.substring(contextPath.length());
        
        // 检查是否为公共资源
        if (isPublicPath(path)) {
            chain.doFilter(req, resp);
            return;
        }
        
        HttpSession session = req.getSession(false);
        User user = null;
        if (session != null) {
            user = (User) session.getAttribute("user");
        }
        
        // 未登录，跳转到登录页
        if (user == null) {
            resp.sendRedirect(contextPath + "/login");
            return;
        }
        
        // 已登录，检查路径
        // /user/ 路径下的所有页面和相关 Servlet 都允许普通用户和管理员访问
        // /admin/ 路径只允许管理员访问
        if (path.startsWith("/admin/")) {
            if (user.getRole() == 1) {
                chain.doFilter(req, resp);
                return;
            } else {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "权限不足");
                return;
            }
        }
        
        // 其他路径（/user/ 开头、Servlet 等）都允许已登录用户访问
        chain.doFilter(req, resp);
    }
    
    private boolean isPublicPath(String path) {
        for (String p : PUBLIC_PATHS) {
            if (path.startsWith(p) || path.contains("_test")) {
                return true;
            }
        }
        return path.equals("/") || path.isEmpty();
    }
    
    @Override
    public void destroy() {
    }
}
