<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.security.MessageDigest"%>
<%!
    // 自己实现MD5，不依赖任何类
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
    
    if (username != null) {
        out.println("<h3>登录测试:</h3>");
        out.println("<p>用户名: " + username + "</p>");
        out.println("<p>密码: " + password + "</p>");
        out.println("<p>密码MD5: " + md5(password) + "</p>");
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/library?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true", "root", "root");
        
        PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM user WHERE username = ?");
        pstmt.setString(1, username);
        ResultSet rs = pstmt.executeQuery();
        
        if (rs.next()) {
            out.println("<p style='color:blue;'>找到用户!</p>");
            out.println("<p>数据库密码: " + rs.getString("password") + "</p>");
            out.println("<p>用户状态: " + rs.getInt("status") + "</p>");
            
            if (md5(password).equals(rs.getString("password"))) {
                out.println("<h2 style='color:green;'>✅ 密码匹配! 登录成功!</h2>");
            } else {
                out.println("<h2 style='color:red;'>❌ 密码不匹配!</h2>");
            }
        } else {
            out.println("<p style='color:red;'>未找到用户!</p>");
        }
        
        rs.close();
        pstmt.close();
        conn.close();
    }
%>

<hr>
<form method="post">
    <input name="username" placeholder="用户名" value="admin"><br>
    <input name="password" placeholder="密码" value="123456"><br>
    <button type="submit">测试登录</button>
</form>
