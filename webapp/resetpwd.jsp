<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="com.library.util.DBUtil"%>
<%@ page import="com.library.util.MD5Util"%>
<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    String action = request.getParameter("action");
    
    if ("reset".equals(action)) {
        try {
            conn = DBUtil.getConnection();
            
            // 重置admin密码为123456
            String newPassword = MD5Util.encrypt("123456");
            pstmt = conn.prepareStatement("UPDATE user SET password = ? WHERE username = 'admin'");
            pstmt.setString(1, newPassword);
            pstmt.executeUpdate();
            pstmt.close();
            
            // 重置test密码为123456
            pstmt = conn.prepareStatement("UPDATE user SET password = ? WHERE username = 'test'");
            pstmt.setString(1, newPassword);
            pstmt.executeUpdate();
            
            out.println("<h3 style='color:green;'>✅ 密码已重置!</h3>");
            out.println("<p>admin / test 密码已重置为: 123456</p>");
            
        } catch (Exception e) {
            out.println("<h3 style='color:red;'>❌ 错误: " + e.getMessage() + "</h3>");
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }
    }
    
    // 显示当前用户
    try {
        conn = DBUtil.getConnection();
        Statement stmt = conn.createStatement();
        rs = stmt.executeQuery("SELECT id, username, password, name, role, status FROM user");
        
        out.println("<h3>当前用户列表:</h3>");
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
        
        out.println("<br><p>123456的MD5值应该是: <code>" + MD5Util.encrypt("123456") + "</code></p>");
        
    } catch (Exception e) {
        out.println("<p style='color:red;'>错误: " + e.getMessage() + "</p>");
    } finally {
        DBUtil.close(rs, null, conn);
    }
%>
<br><br>
<a href="?action=reset">点击重置admin和test密码为 123456</a>
<br><br>
<a href="login.jsp">返回登录页</a>
