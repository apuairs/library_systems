<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/library?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true", "root", "root");
    
    String action = request.getParameter("action");
    
    if ("fix".equals(action)) {
        // 直接使用计算好的MD5值，不调用MD5Util
        String passwordMD5 = "e10adc3949ba59abbe56e057f20f883e"; // 123456的MD5
        
        Statement stmt = conn.createStatement();
        stmt.executeUpdate("UPDATE user SET password = '" + passwordMD5 + "', status = 1 WHERE username IN ('admin', 'test')");
        
        out.println("<h3 style='color:green;'>✅ 已修复!</h3>");
        stmt.close();
    }
    
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("SELECT id, username, password, name, role, status FROM user");
    
    out.println("<h3>数据库用户数据:</h3>");
    out.println("<table border='1' cellpadding='8'>");
    out.println("<tr><th>ID</th><th>用户名</th><th>密码(MD5)</th><th>姓名</th><th>角色</th><th>状态</th></tr>");
    while (rs.next()) {
        out.println("<tr>");
        out.println("<td>" + rs.getInt("id") + "</td>");
        out.println("<td>" + rs.getString("username") + "</td>");
        out.println("<td><code>" + rs.getString("password") + "</code></td>");
        out.println("<td>" + rs.getString("name") + "</td>");
        out.println("<td>" + rs.getInt("role") + "</td>");
        out.println("<td>" + rs.getInt("status") + "</td>");
        out.println("</tr>");
    }
    out.println("</table>");
    
    out.println("<br><p><b>123456 的正确MD5是: <code>e10adc3949ba59abbe56e057f20f883e</code></b></p>");
    
    rs.close();
    stmt.close();
    conn.close();
%>
<br><br>
<a href="?fix=1"><button style="padding:10px 20px;background:green;color:white;border:none;border-radius:5px;cursor:pointer;">一键修复登录问题</button></a>
