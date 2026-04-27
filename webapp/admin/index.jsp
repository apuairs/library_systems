<!-- admin/index.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.library.model.User"%>
<%@ page import="com.library.service.StatisticsService"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRole() != 1) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    StatisticsService statsService = new StatisticsService();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>管理后台 - 图书馆管理系统</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Microsoft YaHei', sans-serif; background: #f4f6f9; }
        
        /* 侧边栏 */
        .sidebar { position: fixed; left: 0; top: 0; width: 260px; height: 100%; background: #2c3e50; color: white; }
        .sidebar-header { padding: 20px; text-align: center; border-bottom: 1px solid #34495e; }
        .sidebar-header h3 { font-size: 18px; }
        .sidebar-nav { padding: 20px 0; }
        .sidebar-nav a { display: block; padding: 12px 20px; color: #ecf0f1; text-decoration: none; transition: all 0.3s; }
        .sidebar-nav a:hover { background: #34495e; padding-left: 25px; }
        .sidebar-nav a.active { background: #3498db; }
        .sidebar-nav .nav-icon { margin-right: 10px; }
        
        /* 主内容区 */
        .main-content { margin-left: 260px; padding: 20px; }
        .top-bar { background: white; padding: 15px 20px; border-radius: 8px; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        .user-info { display: flex; align-items: center; gap: 15px; }
        .logout-btn { background: #e74c3c; padding: 5px 15px; border-radius: 5px; color: white; text-decoration: none; }
        
        /* 统计卡片 */
        .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 30px; }
        .stat-card { background: white; border-radius: 10px; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        .stat-title { color: #7f8c8d; font-size: 14px; margin-bottom: 10px; }
        .stat-value { font-size: 28px; font-weight: bold; color: #2c3e50; }
        .stat-unit { font-size: 14px; color: #95a5a6; margin-left: 5px; }
        
        /* 图表区域 */
        .charts-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 30px; }
        .chart-card { background: white; border-radius: 10px; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        .chart-title { font-size: 16px; font-weight: bold; margin-bottom: 15px; padding-bottom: 10px; border-bottom: 2px solid #3498db; }
        
        .footer { margin-top: 30px; text-align: center; color: #95a5a6; padding: 20px; }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="sidebar-header">
            <h3>📚 图书馆管理系统</h3>
            <p style="font-size: 12px; margin-top: 5px;">管理后台</p>
        </div>
        <div class="sidebar-nav">
            <a href="index.jsp" class="active">
                <span class="nav-icon">📊</span> 仪表盘
            </a>
            <a href="bookList.jsp">
                <span class="nav-icon">📖</span> 图书管理
            </a>
            <a href="userList.jsp">
                <span class="nav-icon">👥</span> 用户管理
            </a>
            <a href="borrowList.jsp">
                <span class="nav-icon">📋</span> 借阅管理
            </a>
            <a href="seatManage.jsp">
                <span class="nav-icon">💺</span> 座位管理
            </a>
            <a href="statistics.jsp">
                <span class="nav-icon">📈</span> 统计分析
            </a>
            <a href="systemConfig.jsp">
                <span class="nav-icon">⚙️</span> 系统设置
            </a>
        </div>
    </div>
    
    <div class="main-content">
        <div class="top-bar">
            <h2>仪表盘</h2>
            <div class="user-info">
                <span>欢迎，<%= user.getName() %></span>
                <a href="<%= request.getContextPath() %>/logout" class="logout-btn">退出</a>
            </div>
        </div>
        
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-title">今日借书</div>
                <div class="stat-value"><%= statsService.getTodayBorrowCount() %></div>
            </div>
            <div class="stat-card">
                <div class="stat-title">今日还书</div>
                <div class="stat-value"><%= statsService.getTodayReturnCount() %></div>
            </div>
            <div class="stat-card">
                <div class="stat-title">逾期图书</div>
                <div class="stat-value"><%= statsService.getOverdueCount() %></div>
            </div>
            <div class="stat-card">
                <div class="stat-title">座位使用率</div>
                <div class="stat-value"><%= String.format("%.1f", statsService.getSeatUsageRate() * 100) %><span class="stat-unit">%</span></div>
            </div>
            <div class="stat-card">
                <div class="stat-title">总用户数</div>
                <div class="stat-value"><%= statsService.getTotalUserCount() %></div>
            </div>
            <div class="stat-card">
                <div class="stat-title">总藏书量</div>
                <div class="stat-value"><%= statsService.getTotalBookCount() %></div>
            </div>
            <div class="stat-card">
                <div class="stat-title">总借阅次数</div>
                <div class="stat-value"><%= statsService.getTotalBorrowCount() %></div>
            </div>
            <div class="stat-card">
                <div class="stat-title">罚款总额</div>
                <div class="stat-value">¥<%= String.format("%.2f", statsService.getTotalFineAmount()) %></div>
            </div>
        </div>
        
        <div class="charts-grid">
            <div class="chart-card">
                <div class="chart-title">近7天借阅趋势</div>
                <canvas id="borrowTrendChart" height="200"></canvas>
            </div>
            <div class="chart-card">
                <div class="chart-title">图书分类借阅统计</div>
                <canvas id="categoryChart" height="200"></canvas>
            </div>
        </div>
        
        <div class="footer">
            <p>© 2024 图书馆管理系统 | 系统运行正常</p>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        // 借阅趋势数据
        fetch('<%= request.getContextPath() %>/api/borrowTrend?days=7')
            .then(res => res.json())
            .then(data => {
                new Chart(document.getElementById('borrowTrendChart'), {
                    type: 'line',
                    data: {
                        labels: data.map(d => d.date),
                        datasets: [{
                            label: '借阅数量',
                            data: data.map(d => d.borrowCount),
                            borderColor: '#3498db',
                            backgroundColor: 'rgba(52, 152, 219, 0.1)',
                            fill: true
                        }]
                    },
                    options: { responsive: true, maintainAspectRatio: true }
                });
            });
        
        // 分类统计数据
        fetch('<%= request.getContextPath() %>/api/categoryStats')
            .then(res => res.json())
            .then(data => {
                new Chart(document.getElementById('categoryChart'), {
                    type: 'pie',
                    data: {
                        labels: data.map(d => d.categoryName || d.date || '分类'),
                        datasets: [{
                            data: data.map(d => d.borrowCount),
                            backgroundColor: ['#3498db', '#e74c3c', '#f39c12', '#27ae60', '#9b59b6']
                        }]
                    },
                    options: { responsive: true, maintainAspectRatio: true }
                });
            });
    </script>
</body>
</html>