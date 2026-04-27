<!-- user/profile_info.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.library.model.User"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>个人中心 - 图书馆管理系统</title>
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
        
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: bold; color: #555; }
        .form-group input { width: 100%; padding: 10px 15px; border: 1px solid #ddd; border-radius: 5px; font-size: 14px; }
        
        .btn { padding: 10px 30px; border: none; border-radius: 5px; cursor: pointer; font-size: 14px; }
        .btn-primary { background: #3498db; color: white; }
        .btn-primary:hover { background: #2980b9; }
        
        .alert { padding: 15px; border-radius: 5px; margin-bottom: 20px; }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        
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
            <h2 class="page-title">👤 个人中心</h2>
            
            <% if (request.getAttribute("message") != null) { %>
            <div class="alert alert-success"><%= request.getAttribute("message") %></div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
            <% } %>
            
            <div class="profile-container">
                <div class="nav-tabs">
                    <button class="nav-tab active" onclick="location.href='<%= request.getContextPath() %>/profile?action=info'">个人信息</button>
                    <button class="nav-tab" onclick="location.href='<%= request.getContextPath() %>/profile?action=password'">修改密码</button>
                    <button class="nav-tab" onclick="location.href='<%= request.getContextPath() %>/profile?action=violations'">违规记录</button>
                </div>
                
                <form action="<%= request.getContextPath() %>/profile" method="post">
                    <input type="hidden" name="action" value="updateInfo">
                    
                    <div class="form-group">
                        <label>用户名</label>
                        <input type="text" value="<%= user.getUsername() %>" disabled>
                    </div>
                    
                    <div class="form-group">
                        <label>姓名</label>
                        <input type="text" name="name" value="<%= user.getName() %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label>手机号</label>
                        <input type="text" name="phone" value="<%= user.getPhone() != null ? user.getPhone() : "" %>">
                    </div>
                    
                    <div class="form-group">
                        <label>邮箱</label>
                        <input type="email" name="email" value="<%= user.getEmail() != null ? user.getEmail() : "" %>">
                    </div>
                    
                    <button type="submit" class="btn btn-primary">保存修改</button>
                </form>
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