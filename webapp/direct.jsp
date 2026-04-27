<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.security.MessageDigest"%>
<%@ page import="java.util.*"%>
<%!
    public static String md5(String plainText) {
        if (plainText == null) return null;
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] digest = md.digest(plainText.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : digest) {
                sb.append(String.format("%02x", b & 0xff));
            }
            return sb.toString();
        } catch (Exception e) {
            return null;
        }
    }
    
    public static class SimpleUser {
        private Integer id;
        private String username;
        private String name;
        private Integer role;
        private Integer status;
        
        public Integer getId() { return id; }
        public void setId(Integer id) { this.id = id; }
        public String getUsername() { return username; }
        public void setUsername(String username) { this.username = username; }
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public Integer getRole() { return role; }
        public void setRole(Integer role) { this.role = role; }
        public Integer getStatus() { return status; }
        public void setStatus(Integer status) { this.status = status; }
    }
%>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String error = "";
    
    if (username != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/library?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true", "root", "root");
            
            // 先修复密码
            Statement stmt0 = conn.createStatement();
            stmt0.executeUpdate("UPDATE user SET password = 'e10adc3949ba59abbe56e057f20f883e', status = 1 WHERE username IN ('admin', 'test')");
            stmt0.close();
            
            PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM user WHERE username = ?");
            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                String dbPwd = rs.getString("password");
                if (dbPwd.equals(md5(password))) {
                    // 登录成功，手动构造User并存入session
                    SimpleUser user = new SimpleUser();
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setName(rs.getString("name"));
                    user.setRole(rs.getInt("role"));
                    user.setStatus(rs.getInt("status"));
                    
                    session.setAttribute("user", user);
                    
                    if (user.getRole() == 1) {
                        response.sendRedirect("admin/index.jsp");
                    } else {
                        response.sendRedirect("user/index.jsp");
                    }
                    return;
                } else {
                    error = "密码错误！DB=" + dbPwd + ", Input=" + md5(password);
                }
            } else {
                error = "用户名不存在！";
            }
            rs.close();
            pstmt.close();
            conn.close();
        } catch (Exception e) {
            error = "错误: " + e.getMessage();
            e.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>直接登录 - 绕过Servlet</title>
    <style>
        body { font-family: Microsoft YaHei; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .login-box { background: white; padding: 40px; border-radius: 10px; width: 350px; }
        h1 { text-align: center; color: #333; margin-bottom: 30px; }
        .error { color: red; text-align: center; margin-bottom: 20px; padding: 10px; background: #ffebee; border-radius: 5px; }
        input { width: 100%; padding: 12px; margin: 10px 0; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; }
        button { width: 100%; padding: 12px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; border-radius: 5px; font-size: 16px; cursor: pointer; margin-top: 10px; }
        .hint { text-align: center; margin-top: 20px; color: #666; font-size: 14px; }
    </style>
</head>
<body>
    <div class="login-box">
        <h1>🔓 直接登录</h1>
        <% if (!error.isEmpty()) { %>
            <div class="error"><%= error %></div>
        <% } %>
        <form method="post">
            <input name="username" placeholder="用户名" value="admin">
            <input name="password" placeholder="密码" value="123456" type="password">
            <button type="submit">无需验证码，直接登录</button>
        </form>
        <div class="hint">
            管理员: admin / 123456<br>
            普通用户: test / 123456
        </div>
    </div>
</body>
</html>
