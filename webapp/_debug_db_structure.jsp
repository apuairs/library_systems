<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.library.util.DBUtil" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>数据库表结构检查</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; background: #f5f5f5; }
        .container { background: white; padding: 20px; border-radius: 8px; max-width: 1200px; margin: 0 auto; }
        h1 { color: #333; }
        h2 { color: #666; margin-top: 30px; }
        table { border-collapse: collapse; width: 100%; margin-top: 10px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #f2f2f2; }
        .error { color: red; font-weight: bold; }
        .success { color: green; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 数据库表结构检查</h1>
        
        <%
            Connection conn = null;
            ResultSet rs = null;
            try {
                conn = DBUtil.getConnection();
                DatabaseMetaData metaData = conn.getMetaData();
                
                // 检查 borrow_record 表
        %>
                <h2>1. 检查 borrow_record 表</h2>
                <table>
                    <tr><th>列名</th><th>类型</th><th>备注</th></tr>
        <%
                rs = metaData.getColumns(null, null, "borrow_record", null);
                while (rs.next()) {
                    String columnName = rs.getString("COLUMN_NAME");
                    String columnType = rs.getString("TYPE_NAME");
                    String remarks = rs.getString("REMARKS");
        %>
                    <tr>
                        <td><%= columnName %></td>
                        <td><%= columnType %></td>
                        <td><%= remarks %></td>
                    </tr>
        <%
                }
                rs.close();
                
                // 检查是否有 borrow_time 字段
                rs = metaData.getColumns(null, null, "borrow_record", "borrow_time");
                if (rs.next()) {
        %>
                    <p class="error">❌ 表中包含 borrow_time 字段！</p>
        <%
                } else {
        %>
                    <p class="success">✅ 表中没有 borrow_time 字段（符合预期）</p>
        <%
                }
                rs.close();
                
                // 检查是否有 borrow_date 字段
                rs = metaData.getColumns(null, null, "borrow_record", "borrow_date");
                if (rs.next()) {
        %>
                    <p class="success">✅ 表中包含 borrow_date 字段（符合预期）</p>
        <%
                } else {
        %>
                    <p class="error">❌ 表中缺少 borrow_date 字段！</p>
        <%
                }
                rs.close();
                
                // 检查 operator_id 和 fine_amount 字段
                String[] requiredFields = {"operator_id", "fine_amount", "due_date", "return_date"};
                for (String field : requiredFields) {
                    rs = metaData.getColumns(null, null, "borrow_record", field);
                    if (rs.next()) {
        %>
                        <p class="success">✅ 表中包含 <%= field %> 字段</p>
        <%
                    } else {
        %>
                        <p class="error">❌ 表中缺少 <%= field %> 字段！</p>
        <%
                    }
                    rs.close();
                }
                
        %>
                
                <h2>2. 当前数据</h2>
                <h3>用户表</h3>
                <table>
                    <tr><th>ID</th><th>用户名</th><th>姓名</th><th>角色</th><th>状态</th></tr>
        <%
                Statement stmt = conn.createStatement();
                rs = stmt.executeQuery("SELECT id, username, name, role, status FROM user");
                while (rs.next()) {
        %>
                    <tr>
                        <td><%= rs.getInt("id") %></td>
                        <td><%= rs.getString("username") %></td>
                        <td><%= rs.getString("name") %></td>
                        <td><%= rs.getInt("role") %></td>
                        <td><%= rs.getInt("status") %></td>
                    </tr>
        <%
                }
                rs.close();
                
        %>
                <h3>图书表（前5条）</h3>
                <table>
                    <tr><th>ID</th><th>书名</th><th>总数</th><th>可借</th><th>状态</th></tr>
        <%
                rs = stmt.executeQuery("SELECT id, title, total_count, available_count, status FROM book LIMIT 5");
                while (rs.next()) {
        %>
                    <tr>
                        <td><%= rs.getInt("id") %></td>
                        <td><%= rs.getString("title") %></td>
                        <td><%= rs.getInt("total_count") %></td>
                        <td><%= rs.getInt("available_count") %></td>
                        <td><%= rs.getInt("status") %></td>
                    </tr>
        <%
                }
                rs.close();
                stmt.close();
                
            } catch (Exception e) {
                e.printStackTrace();
        %>
                <p class="error">错误：<%= e.getMessage() %></p>
                <pre><%
                    StringWriter sw = new StringWriter();
                    e.printStackTrace(new PrintWriter(sw));
                    out.print(sw.toString());
                %></pre>
        <%
            } finally {
                if (rs != null) rs.close();
                if (conn != null) conn.close();
            }
        %>
        
        <h2>3. 修复建议</h2>
        <p>如果发现缺少字段，请执行以下 SQL 语句：</p>
        <pre>
ALTER TABLE borrow_record 
ADD COLUMN operator_id INT COMMENT '操作人ID',
ADD COLUMN fine_amount DECIMAL(10,2) DEFAULT 0 COMMENT '罚款金额';
        </pre>
        
        <p style="margin-top: 20px;"><a href="login.jsp">返回登录页</a></p>
    </div>
</body>
</html>
