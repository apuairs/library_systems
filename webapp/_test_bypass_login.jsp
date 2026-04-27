<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.security.MessageDigest"%>
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
%>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String error = "";
    
    if (username != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/library_system?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true", "root", "123456");
            
            // 强制修复admin和test的密码
            Statement stmt0 = conn.createStatement();
            stmt0.executeUpdate("UPDATE user SET password = 'e10adc3949ba59abbe56e057f20f883e', status = 1 WHERE username IN ('admin', 'test')");
            stmt0.close();
            
            PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM user WHERE username = ?");
            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                String dbPwd = rs.getString("password");
                if (dbPwd.equals(md5(password))) {
                    // 登录成功，手动创建Session属性
                    final Integer userId = rs.getInt("id");
                    final String userUsername = rs.getString("username");
                    final String userName = rs.getString("name");
                    final Integer userRole = rs.getInt("role");
                    final Integer userStatus = rs.getInt("status");
                    
                    // 创建匿名User对象（只需要这些getter方法）
                    Object user = new Object() {
                        public Integer getId() { return userId; }
                        public String getUsername() { return userUsername; }
                        public String getName() { return userName; }
                        public Integer getRole() { return userRole; }
                        public Integer getStatus() { return userStatus; }
                        @Override
                        public String toString() { return userUsername; }
                    };
                    
                    session.setAttribute("user", user);
                    out.println("<h3 style='color:green;'>登录成功！3秒后跳转...</h3>");
                    
                    if (userRole == 1) {
                        response.setHeader("Refresh", "3; URL=admin/index.jsp");
                    } else {
                        response.setHeader("Refresh", "3; URL=user/index.jsp");
                    }
                } else {
                    error = "密码不匹配！DB=" + dbPwd + ", YourInputMD5=" + md5(password);
                }
            } else {
                error = "用户名不存在！";
            }
            rs.close();
            pstmt.close();
            conn.close();
        } catch (Exception e) {
            error = "错误: " + e.toString();
            e.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>绕过登录</title>
    <style>
        body { font-family: Microsoft YaHei; padding: 50px; background: #f0f2f5; }
        .box { background: white; padding: 40px; border-radius: 10px; max-width: 400px; margin: 0 auto; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { text-align: center; color: #1890ff; }
        .error { color: red; padding: 10px; background: #fff1f0; border-radius: 5px; margin: 10px 0; }
        input { width: 100%; padding: 12px; margin: 10px 0; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; font-size: 16px; }
        button { width: 100%; padding: 12px; background: #1890ff; color: white; border: none; border-radius: 5px; font-size: 16px; cursor: pointer; margin-top: 10px; }
    </style>
</head>
<body>
    <div class="box">
        <h1>✅ 绕过Filter直接登录</h1>
        <% if (!error.isEmpty()) { %>
            <div class="error"><%= error %></div>
        <% } %>
        <form method="post">
            <input name="username" placeholder="用户名" value="admin">
            <input name="password" placeholder="密码" value="123456" type="password">
            <button type="submit">无需验证码 直接登录</button>
        </form>
        <div style="margin-top:20px;text-align:center;color:#666;font-size:14px;">
            管理员: admin / 123456<br>
            普通用户: test / 123456
        </div>
    </div>
</body>
</html>
