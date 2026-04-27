<!-- user/profile_violations.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.library.model.User"%>
<%@ page import="com.library.model.Violation"%>
<%@ page import="java.util.List"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    List<Violation> violations = (List<Violation>) request.getAttribute("violations");
    if (violations == null) {
        violations = new java.util.ArrayList<Violation>();
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>违规记录 - 图书馆管理系统</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Microsoft YaHei', sans-serif; background: #f5f5f5; }
        
        .header { background: #2c3e50; color: white; padding: 15px 0; }
        .container { width: 1200px; margin: 0 auto; }
        .header .container { display: flex; justify-content: space-between; align-items: center; }
        .logo { font-size: 24px; font-weight: bold; }
        .nav { display: flex; gap: 30px; }
        .nav a { color: white; text-decoration: none; }
        .user-info { display: flex; align-items: center; gap: 15px; }
        .logout-btn { background: #e74c3c; padding: 5px 15px; border-radius: 5px; color: white; text-decoration: none; }
        
        .main { padding: 30px 0; }
        .page-title { margin-bottom: 30px; color: #333; }
        
        .profile-container { background: white; border-radius: 10px; padding: 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        
        .nav-tabs { display: flex; gap: 20px; margin-bottom: 30px; border-bottom: 2px solid #ddd; }
        .nav-tab { padding: 10px 20px; cursor: pointer; border: none; background: none; font-size: 16px; }
        .nav-tab.active { color: #3498db; border-bottom: 2px solid #3498db; margin-bottom: -2px; }
        
        .violation-table { width: 100%; border-collapse: collapse; }
        .violation-table th, .violation-table td { padding: 15px; text-align: left; border-bottom: 1px solid #eee; }
        .violation-table th { background: #f8f9fa; font-weight: bold; color: #555; }
        .violation-table tr:hover { background: #fafafa; }
        
        .status-unhandled { color: #e74c3c; font-weight: bold; }
        .status-handled { color: #27ae60; }
        
        .empty-msg { text-align: center; padding: 50px; color: #999; }
        
        .footer { background: #2c3e50; color: #95a5a6; text-align: center; padding: 20px 0; margin-top: 50px; }
    </style>
</head>
<body>
    <div class="header">
        <div class="container">
            <div class="logo">📚 图书馆管理系统</div>
            <div class="nav">
                <a href="index.jsp">首页</a>
                <a href="search.jsp">图书检索</a>
                <a href="seat.jsp">座位预约</a>
                <a href="borrowing.jsp">我的借阅</a>
            </div>
            <div class="user-info">
                <span>欢迎，<%= user.getName() %></span>
                <a href="<%= request.getContextPath() %>/logout" class="logout-btn">退出</a>
            </div>
        </div>
    </div>
    
    <div class="main">
        <div class="container">
            <h2 class="page-title">⚠️ 违规记录</h2>
            
            <div class="profile-container">
                <div class="nav-tabs">
                    <button class="nav-tab" onclick="location.href='<%= request.getContextPath() %>/profile?action=info'">个人信息</button>
                    <button class="nav-tab" onclick="location.href='<%= request.getContextPath() %>/profile?action=password'">修改密码</button>
                    <button class="nav-tab active" onclick="location.href='<%= request.getContextPath() %>/profile?action=violations'">违规记录</button>
                </div>
                
                <% if (violations.isEmpty()) { %>
                <div class="empty-msg">暂无违规记录</div>
                <% } else { %>
                <table class="violation-table">
                    <thead>
                        <tr>
                            <th>违规时间</th>
                            <th>违规类型</th>
                            <th>违规原因</th>
                            <th>处理状态</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Violation violation : violations) { %>
                        <tr>
                            <td><%= sdf.format(violation.getCreateTime()) %></td>
                            <td><%= violation.getType() == 1 ? "逾期还书" : "其他违规" %></td>
                            <td><%= violation.getReason() %></td>
                            <td><span class="<%= violation.getHandleStatus() == 0 ? "status-unhandled" : "status-handled" %>">
                                <%= violation.getHandleStatus() == 0 ? "未处理" : "已处理" %>
                            </span></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } %>
            </div>
        </div>
    </div>
    
    <div class="footer">
        <div class="container">
            <p>© 2024 图书馆管理系统</p>
        </div>
    </div>
</body>
</html>