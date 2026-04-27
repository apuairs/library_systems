<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.library.model.User"%>
<%@ page import="com.library.service.SeatService"%>
<%@ page import="com.library.model.SeatReservation"%>
<%@ page import="java.util.List"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    SeatService seatService = new SeatService();
    List<SeatReservation> reservations = seatService.getMyReservations(user.getId());
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的座位预约 - 图书馆管理系统</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Microsoft YaHei', sans-serif; background: #f5f5f5; }
        
        .header { background: #2c3e50; color: white; padding: 15px 0; }
        .container { width: 1200px; margin: 0 auto; }
        .header .container { display: flex; justify-content: space-between; align-items: center; }
        .logo { font-size: 24px; font-weight: bold; }
        .nav { display: flex; gap: 30px; }
        .nav a { color: white; text-decoration: none; }
        .nav a:hover, .nav a.active { color: #3498db; }
        .user-info { display: flex; align-items: center; gap: 15px; }
        
        .main { padding: 30px 0; }
        .page-title { margin-bottom: 20px; color: #333; }
        
        .alert { padding: 15px; border-radius: 5px; margin-bottom: 20px; }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        
        .reservation-list { background: white; border-radius: 10px; padding: 20px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        
        .reservation-item {
            border-bottom: 1px solid #eee;
            padding: 20px 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .reservation-item:last-child { border-bottom: none; }
        
        .reservation-info h3 { margin-bottom: 10px; color: #333; }
        .reservation-info p { color: #666; margin-bottom: 5px; }
        
        .status-badge {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }
        .status-0 { background: #e3f2fd; color: #1976d2; } /* 待签到 */
        .status-1 { background: #e8f5e9; color: #388e3c; } /* 已签到 */
        .status-2 { background: #f3e5f5; color: #7b1fa2; } /* 已签退 */
        .status-3 { background: #fff3e0; color: #f57c00; } /* 已取消 */
        .status-4 { background: #ffebee; color: #c62828; } /* 爽约 */
        
        .action-btns { display: flex; gap: 10px; margin-top: 10px; }
        .btn {
            padding: 8px 15px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            text-decoration: none;
            display: inline-block;
        }
        .btn-primary { background: #3498db; color: white; }
        .btn-success { background: #27ae60; color: white; }
        .btn-danger { background: #e74c3c; color: white; }
        .btn:hover { opacity: 0.9; }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }
        .empty-state .icon { font-size: 64px; margin-bottom: 20px; }
        
        .rules-box {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            border-radius: 5px;
            padding: 15px;
            margin-bottom: 20px;
        }
        .rules-box h4 { margin-bottom: 10px; color: #856404; }
        .rules-box ul { margin-left: 20px; color: #856404; }
        .rules-box li { margin-bottom: 5px; }
        
        .footer {
            background: #2c3e50;
            color: #95a5a6;
            text-align: center;
            padding: 20px 0;
            margin-top: 50px;
        }
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
            </div>
        </div>
    </div>
    
    <div class="main">
        <div class="container">
            <h2 class="page-title">💺 我的座位预约</h2>
            
            <% if (request.getAttribute("message") != null) { %>
            <div class="alert alert-success"><%= request.getAttribute("message") %></div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
            <% } %>
            
            <div class="rules-box">
                <h4>📋 座位预约规则</h4>
                <ul>
                    <li>预约成功后，请在预约开始时间前30分钟内到达图书馆签到</li>
                    <li>超过预约开始时间30分钟未签到，系统将自动取消预约并记录为爽约</li>
                    <li>累计3次爽约将被记录为违规，可能影响后续预约权限</li>
                    <li>预约开始前1小时内无法取消预约</li>
                </ul>
            </div>
            
            <div class="reservation-list">
                <% if (reservations != null && !reservations.isEmpty()) { %>
                    <% for (SeatReservation r : reservations) { 
                        String statusText = "";
                        String statusClass = "";
                        switch (r.getStatus()) {
                            case 0: statusText = "待签到"; statusClass = "status-0"; break;
                            case 1: statusText = "已签到"; statusClass = "status-1"; break;
                            case 2: statusText = "已签退"; statusClass = "status-2"; break;
                            case 3: statusText = "已取消"; statusClass = "status-3"; break;
                            case 4: statusText = "爽约"; statusClass = "status-4"; break;
                        }
                    %>
                    <div class="reservation-item">
                        <div class="reservation-info">
                            <h3>座位 <%= r.getSeatNumber() %> (<%= r.getArea() %>区)</h3>
                            <p>📅 预约日期：<%= r.getReserveDate() %></p>
                            <p>🕐 预约时间：<%= r.getStartTime() %> - <%= r.getEndTime() %></p>
                            <p>⏰ 预约时间：<%= sdf.format(r.getReserveTime()) %></p>
                            <span class="status-badge <%= statusClass %>"><%= statusText %></span>
                            
                            <% if (r.getStatus() != null && r.getStatus().equals(0)) { %>
                            <div class="action-btns">
                                <a href="<%= request.getContextPath() %>/seatCheckIn?reservationId=<%= r.getId() %>" class="btn btn-success">签到</a>
                                <a href="<%= request.getContextPath() %>/cancelSeatReservation?reservationId=<%= r.getId() %>" class="btn btn-danger" onclick="return confirm('确定要取消此预约吗？')">取消预约</a>
                            </div>
                            <% } else if (r.getStatus() != null && r.getStatus().equals(1)) { %>
                            <div class="action-btns">
                                <a href="<%= request.getContextPath() %>/seatCheckOut?reservationId=<%= r.getId() %>" class="btn btn-primary">签退</a>
                            </div>
                            <% } %>
                        </div>
                    </div>
                    <% } %>
                <% } else { %>
                    <div class="empty-state">
                        <div class="icon">📭</div>
                        <p>暂无座位预约记录</p>
                        <p><a href="seat.jsp" class="btn btn-primary">去预约座位</a></p>
                    </div>
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
