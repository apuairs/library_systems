<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.library.model.User"%>
<%@ page import="com.library.model.Seat"%>
<%@ page import="com.library.model.SeatReservation"%>
<%@ page import="com.library.service.SeatService"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRole() != 1) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    SeatService seatService = new SeatService();
    List<Seat> seats = seatService.getAllSeats();
    List<SeatReservation> reservations = seatService.getAllReservations();
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String today = sdf.format(new Date());
    
    int totalSeats = seats != null ? seats.size() : 0;
    int availableSeats = 0;
    int reservedSeats = 0;
    int occupiedSeats = 0;
    
    Map<Integer, SeatReservation> todayReservations = new HashMap<>();
    if (reservations != null) {
        for (SeatReservation r : reservations) {
            if (today.equals(r.getReserveDate()) && (r.getStatus().equals(0) || r.getStatus().equals(1))) {
                todayReservations.put(r.getSeatId(), r);
                if (r.getStatus().equals(0)) {
                    reservedSeats++;
                } else if (r.getStatus().equals(1)) {
                    occupiedSeats++;
                }
            }
        }
    }
    
    if (seats != null) {
        for (Seat s : seats) {
            if (s.getStatus() == 1 && !todayReservations.containsKey(s.getId())) {
                availableSeats++;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>座位管理 - 图书馆管理系统</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Microsoft YaHei', sans-serif; background: #f5f7fa; min-height: 100vh; }
        .admin-layout { display: flex; min-height: 100vh; }
        
        .sidebar { width: 220px; background: linear-gradient(180deg, #304156 0%, #1f2d3d 100%); color: white; }
        .sidebar-header { padding: 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.1); }
        .sidebar-header h1 { font-size: 18px; font-weight: 500; }
        .sidebar-menu { list-style: none; padding: 10px 0; }
        .sidebar-menu li { margin-bottom: 2px; }
        .sidebar-menu a { display: block; padding: 14px 20px; color: rgba(255,255,255,0.8); text-decoration: none; transition: all 0.3s; border-left: 3px solid transparent; }
        .sidebar-menu a:hover, .sidebar-menu a.active { background: rgba(255,255,255,0.1); color: #409eff; border-left-color: #409eff; }
        
        .main-content { flex: 1; display: flex; flex-direction: column; }
        .top-header { height: 60px; background: white; box-shadow: 0 1px 4px rgba(0,0,0,0.1); display: flex; align-items: center; justify-content: space-between; padding: 0 20px; }
        .header-left { font-size: 16px; color: #304156; font-weight: 500; }
        .header-right { display: flex; align-items: center; gap: 15px; }
        .user-info { display: flex; align-items: center; gap: 8px; color: #606266; }
        .logout-btn { padding: 6px 15px; background: #f56c6c; color: white; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; font-size: 13px; }
        
        .page-content { padding: 20px; flex: 1; }
        .page-header { margin-bottom: 20px; }
        .page-header h2 { font-size: 22px; color: #303133; margin-bottom: 5px; }
        .page-header p { color: #909399; font-size: 14px; }
        
        .stats-cards { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 20px; }
        .stat-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 12px rgba(0,0,0,0.05); }
        .stat-value { font-size: 32px; font-weight: bold; color: #409eff; margin-bottom: 5px; }
        .stat-label { color: #909399; font-size: 14px; }
        
        .seat-map-container { background: white; padding: 20px; border-radius: 8px; }
        .seat-map-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .seat-map-header h3 { font-size: 16px; color: #303133; }
        .seat-legend { display: flex; gap: 20px; }
        .legend-item { display: flex; align-items: center; gap: 5px; font-size: 12px; color: #606266; }
        .legend-color { width: 20px; height: 20px; border-radius: 4px; }
        .legend-available { background: #67c23a; }
        .legend-occupied { background: #f56c6c; }
        .legend-reserved { background: #e6a23c; }
        .legend-maintenance { background: #909399; }
        
        .seat-grid { display: flex; flex-wrap: wrap; gap: 10px; justify-content: center; }
        .seat { width: 60px; height: 60px; border-radius: 6px; display: flex; flex-direction: column; align-items: center; justify-content: center; font-size: 11px; cursor: pointer; transition: all 0.2s; border: none; }
        .seat-available { background: #67c23a; color: white; }
        .seat-available:hover { background: #85ce61; transform: scale(1.05); }
        .seat-occupied { background: #f56c6c; color: white; }
        .seat-reserved { background: #e6a23c; color: white; }
        .seat-maintenance { background: #909399; color: white; cursor: not-allowed; }
        .seat-number { font-weight: bold; font-size: 12px; }
        .seat-status { font-size: 10px; margin-top: 2px; }
        .area-label { font-size: 14px; color: #303133; margin: 15px 0 10px 0; text-align: center; font-weight: 500; background: #f0f2f5; padding: 8px; border-radius: 4px; }
        
        .reservation-list { background: white; padding: 20px; border-radius: 8px; margin-top: 20px; }
        .reservation-list h3 { font-size: 16px; color: #303133; margin-bottom: 15px; }
        .reservation-table { width: 100%; border-collapse: collapse; }
        .reservation-table th, .reservation-table td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
        .reservation-table th { background: #f5f7fa; color: #606266; font-weight: 500; }
        .status-badge { display: inline-block; padding: 4px 10px; border-radius: 12px; font-size: 12px; }
        .status-0 { background: #e3f2fd; color: #1976d2; }
        .status-1 { background: #e8f5e9; color: #388e3c; }
        .status-2 { background: #f3e5f5; color: #7b1fa2; }
        .status-3 { background: #fff3e0; color: #f57c00; }
        .status-4 { background: #ffebee; color: #c62828; }
    </style>
</head>
<body>
    <div class="admin-layout">
        <div class="sidebar">
            <div class="sidebar-header">
                <h1>📚 管理后台</h1>
            </div>
            <ul class="sidebar-menu">
                <li><a href="index.jsp">📊 仪表盘</a></li>
                <li><a href="bookList.jsp">📚 图书管理</a></li>
                <li><a href="userList.jsp">👥 用户管理</a></li>
                <li><a href="borrowList.jsp">📋 借阅管理</a></li>
                <li><a href="seatManage.jsp" class="active">💺 座位管理</a></li>
                <li><a href="statistics.jsp">📈 统计分析</a></li>
                <li><a href="settings.jsp">⚙️ 系统设置</a></li>
            </ul>
        </div>
        
        <div class="main-content">
            <div class="top-header">
                <div class="header-left">座位管理</div>
                <div class="header-right">
                    <div class="user-info">
                        <span>👤 <%= user.getName() %></span>
                        <span>(管理员)</span>
                    </div>
                    <a href="../logout" class="logout-btn">退出登录</a>
                </div>
            </div>
            
            <div class="page-content">
                <div class="page-header">
                    <h2>座位管理</h2>
                    <p>查看和管理图书馆座位预约情况 - 今日：<%= today %></p>
                </div>
                
                <div class="stats-cards">
                    <div class="stat-card">
                        <div class="stat-value"><%= totalSeats %></div>
                        <div class="stat-label">总座位数</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value" style="color: #67c23a;"><%= availableSeats %></div>
                        <div class="stat-label">空闲座位</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value" style="color: #e6a23c;"><%= reservedSeats %></div>
                        <div class="stat-label">已预约</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value" style="color: #f56c6c;"><%= occupiedSeats %></div>
                        <div class="stat-label">使用中</div>
                    </div>
                </div>
                
                <div class="seat-map-container">
                    <div class="seat-map-header">
                        <h3>座位分布图</h3>
                        <div class="seat-legend">
                            <div class="legend-item">
                                <div class="legend-color legend-available"></div>
                                <span>空闲</span>
                            </div>
                            <div class="legend-item">
                                <div class="legend-color legend-reserved"></div>
                                <span>已预约</span>
                            </div>
                            <div class="legend-item">
                                <div class="legend-color legend-occupied"></div>
                                <span>使用中</span>
                            </div>
                            <div class="legend-item">
                                <div class="legend-color legend-maintenance"></div>
                                <span>维护中</span>
                            </div>
                        </div>
                    </div>
                    
                    <div id="seatMap">
                        <%
                        if (seats != null && !seats.isEmpty()) {
                            String currentArea = "";
                            for (Seat seat : seats) {
                                if (!seat.getArea().equals(currentArea)) {
                                    if (!currentArea.isEmpty()) {
                        %>
                                    </div>
                        <%
                                    }
                                    currentArea = seat.getArea();
                        %>
                                    <div class="area-label"><%= currentArea %>区</div>
                                    <div class="seat-grid">
                        <%
                                }
                                SeatReservation r = todayReservations.get(seat.getId());
                                String seatClass = "";
                                String seatStatus = "";
                                String seatInfo = "";
                                
                                if (seat.getStatus() == 0) {
                                    seatClass = "seat-maintenance";
                                    seatStatus = "维护中";
                                    seatInfo = "座位维护中";
                                } else if (r != null) {
                                    if (r.getStatus().equals(0)) {
                                        seatClass = "seat-reserved";
                                        seatStatus = "已预约";
                                        seatInfo = "预约人: " + r.getUserName() + "\\n时间: " + r.getStartTime() + " - " + r.getEndTime();
                                    } else if (r.getStatus().equals(1)) {
                                        seatClass = "seat-occupied";
                                        seatStatus = "使用中";
                                        seatInfo = "使用人: " + r.getUserName();
                                    }
                                } else {
                                    seatClass = "seat-available";
                                    seatStatus = "空闲";
                                    seatInfo = "座位空闲";
                                }
                        %>
                                <button class="seat <%= seatClass %>" onclick="showSeatInfo('<%= seat.getSeatNumber() %>', '<%= seatStatus %>', '<%= seatInfo %>')">
                                    <span class="seat-number"><%= seat.getSeatNumber() %></span>
                                    <span class="seat-status"><%= seatStatus %></span>
                                </button>
                        <%
                            }
                        %>
                            </div>
                        <%
                        } else {
                        %>
                            <div style="text-align: center; padding: 50px; color: #999;">暂无座位数据</div>
                        <%
                        }
                        %>
                    </div>
                </div>
                
                <div class="reservation-list">
                    <h3>今日预约记录</h3>
                    <table class="reservation-table">
                        <thead>
                            <tr>
                                <th>预约ID</th>
                                <th>用户</th>
                                <th>座位号</th>
                                <th>预约时间</th>
                                <th>状态</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            if (reservations != null) {
                                for (SeatReservation r : reservations) {
                                    if (today.equals(r.getReserveDate())) {
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
                            <tr>
                                <td><%= r.getId() %></td>
                                <td><%= r.getUserName() != null ? r.getUserName() : "未知" %></td>
                                <td><%= r.getSeatNumber() != null ? r.getSeatNumber() : "未知" %> (<%= r.getArea() != null ? r.getArea() : "未知" %>区)</td>
                                <td><%= r.getStartTime() %> - <%= r.getEndTime() %></td>
                                <td><span class="status-badge <%= statusClass %>"><%= statusText %></span></td>
                            </tr>
                            <%
                                    }
                                }
                            }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        function showSeatInfo(seatNumber, status, info) {
            alert('座位信息\n\n座位号: ' + seatNumber + '\n状态: ' + status + '\n\n' + info);
        }
    </script>
</body>
</html>
