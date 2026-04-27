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
        "/login", "/login.jsp", "/register", "/register.jsp", "/logout", "/captcha", "/css/", "/js/", "/images/", "/index.jsp",
        "/testlogin.jsp", "/fix.jsp", "/resetpwd.jsp", "/_debug_db.jsp", "/_test_"
    );
    
    private static final List<String> USER_PATHS = Arrays.asList(
        "/user/", "/profile", "/searchBook", "/borrowBook", "/returnBook", 
        "/renewBook", "/reserveBook", "/seatReserve", "/seatCheckIn", 
        "/seatCheckOut", "/cancelSeatReservation"
    );
    
    private static final List<String> ALL_USER_PATHS = Arrays.asList(
        "/api/"
    );
    
    private static final List<String> ADMIN_PATHS = Arrays.asList(
        "/admin/"
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
        
        // 检查权限
        if (isUserPath(path) && user.getRole() == 0) {
            chain.doFilter(req, resp);
            return;
        }
        
        if (isAdminPath(path) && user.getRole() == 1) {
            chain.doFilter(req, resp);
            return;
        }
        
        if (isAllUserPath(path) && (user.getRole() == 0 || user.getRole() == 1)) {
            chain.doFilter(req, resp);
            return;
        }
        
        // 权限不足
        resp.sendError(HttpServletResponse.SC_FORBIDDEN, "权限不足");
    }
    
    private boolean isPublicPath(String path) {
        for (String p : PUBLIC_PATHS) {
            if (path.startsWith(p) || path.contains("_test")) {
                return true;
            }
        }
        return path.equals("/") || path.isEmpty();
    }
    
    private boolean isUserPath(String path) {
        for (String p : USER_PATHS) {
            if (path.startsWith(p)) {
                return true;
            }
        }
        return false;
    }
    
    private boolean isAdminPath(String path) {
        for (String p : ADMIN_PATHS) {
            if (path.startsWith(p)) {
                return true;
            }
        }
        return false;
    }
    
    private boolean isAllUserPath(String path) {
        for (String p : ALL_USER_PATHS) {
            if (path.startsWith(p)) {
                return true;
            }
        }
        return false;
    }
    
    @Override
    public void destroy() {
    }
}