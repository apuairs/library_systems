<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="com.library.util.DBUtil"%>
<%@ page import="com.library.util.MD5Util"%>
<%
    out.println("<h2>数据库连接测试</h2>");
    
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    
    try {
        conn = DBUtil.getConnection();
        out.println("<p style='color:green;'>✅ 数据库连接成功!</p>");
        
        stmt = conn.createStatement();
        
        // 检查user表是否存在
        out.println("<h3>用户列表:</h3>");
        rs = stmt.executeQuery("SELECT id, username, password, name, role, status FROM user");
        
        out.println("<table border='1' cellpadding='5'>");
        out.println("<tr><th>ID</th><th>用户名</th><th>密码(MD5)</th><th>姓名</th><th>角色</th><th>状态</th></tr>");
        while (rs.next()) {
            out.println("<tr>");
            out.println("<td>" + rs.getInt("id") + "</td>");
            out.println("<td>" + rs.getString("username") + "</td>");
            out.println("<td>" + rs.getString("password") + "</td>");
            out.println("<td>" + rs.getString("name") + "</td>");
            out.println("<td>" + rs.getInt("role") + "</td>");
            out.println("<td>" + rs.getInt("status") + "</td>");
            out.println("</tr>");
        }
        out.println("</table>");
        
        out.println("<h3>MD5测试:</h3>");
        out.println("<p>'123456'的MD5值: " + MD5Util.encode("123456") + "</p>");
        out.println("<p>'admin123'的MD5值: " + MD5Util.encode("admin123") + "</p>");
        
    } catch (Exception e) {
        out.println("<p style='color:red;'>❌ 数据库连接失败: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        DBUtil.close(rs, stmt, conn);
    }
%>
