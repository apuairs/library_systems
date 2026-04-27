<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>统计分析 - 图书馆管理系统</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Microsoft YaHei', sans-serif; background: #f5f7fa; min-height: 100vh; }
        .admin-layout { display: flex; min-height: 100vh; }
        
        /* 侧边栏 */
        .sidebar { width: 220px; background: linear-gradient(180deg, #304156 0%, #1f2d3d 100%); color: white; }
        .sidebar-header { padding: 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.1); }
        .sidebar-header h1 { font-size: 18px; font-weight: 500; }
        .sidebar-menu { list-style: none; padding: 10px 0; }
        .sidebar-menu li { margin-bottom: 2px; }
        .sidebar-menu a { display: block; padding: 14px 20px; color: rgba(255,255,255,0.8); text-decoration: none; transition: all 0.3s; border-left: 3px solid transparent; }
        .sidebar-menu a:hover, .sidebar-menu a.active { background: rgba(255,255,255,0.1); color: #409eff; border-left-color: #409eff; }
        .sidebar-menu i { margin-right: 10px; width: 20px; text-align: center; }
        
        /* 主内容区 */
        .main-content { flex: 1; display: flex; flex-direction: column; }
        .top-header { height: 60px; background: white; box-shadow: 0 1px 4px rgba(0,0,0,0.1); display: flex; align-items: center; justify-content: space-between; padding: 0 20px; }
        .header-left { font-size: 16px; color: #304156; font-weight: 500; }
        .header-right { display: flex; align-items: center; gap: 15px; }
        .user-info { display: flex; align-items: center; gap: 8px; color: #606266; }
        .logout-btn { padding: 6px 15px; background: #f56c6c; color: white; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; font-size: 13px; }
        .logout-btn:hover { background: #e64340; }
        
        /* 内容区 */
        .page-content { padding: 20px; flex: 1; }
        .page-header { margin-bottom: 20px; }
        .page-header h2 { font-size: 22px; color: #303133; margin-bottom: 5px; }
        .page-header p { color: #909399; font-size: 14px; }
        
        /* 统计卡片 */
        .stats-cards { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 20px; }
        .stat-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 12px rgba(0,0,0,0.05); display: flex; align-items: center; gap: 15px; }
        .stat-icon { width: 60px; height: 60px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 28px; }
        .stat-icon.blue { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
        .stat-icon.green { background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); }
        .stat-icon.orange { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); }
        .stat-icon.purple { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); }
        .stat-info { flex: 1; }
        .stat-value { font-size: 28px; font-weight: bold; color: #303133; margin-bottom: 5px; }
        .stat-label { color: #909399; font-size: 14px; }
        
        /* 图表区域 */
        .chart-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin-bottom: 20px; }
        .chart-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 12px rgba(0,0,0,0.05); }
        .chart-card h3 { font-size: 16px; color: #303133; margin-bottom: 20px; padding-bottom: 15px; border-bottom: 1px solid #ebeef5; }
        .chart-container { height: 300px; position: relative; }
        
        /* 全宽图表 */
        .chart-full { grid-column: 1 / -1; }
        
        /* 数据表格 */
        .data-table { background: white; border-radius: 8px; padding: 20px; box-shadow: 0 2px 12px rgba(0,0,0,0.05); }
        .data-table h3 { font-size: 16px; color: #303133; margin-bottom: 20px; padding-bottom: 15px; border-bottom: 1px solid #ebeef5; }
        .data-table table { width: 100%; border-collapse: collapse; }
        .data-table th, .data-table td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #ebeef5; }
        .data-table th { background: #f5f7fa; color: #909399; font-weight: 500; font-size: 14px; }
        .data-table td { color: #606266; font-size: 14px; }
        .rank { display: inline-block; width: 24px; height: 24px; border-radius: 50%; text-align: center; line-height: 24px; font-size: 12px; font-weight: bold; margin-right: 10px; }
        .rank-1 { background: #f56c6c; color: white; }
        .rank-2 { background: #e6a23c; color: white; }
        .rank-3 { background: #409eff; color: white; }
        .rank-other { background: #f0f2f5; color: #909399; }
    </style>
</head>
<body>
    <div class="admin-layout">
        <!-- 侧边栏 -->
        <div class="sidebar">
            <div class="sidebar-header">
                <h1>📚 管理后台</h1>
            </div>
            <ul class="sidebar-menu">
                <li><a href="index.jsp"><i>📊</i> 仪表盘</a></li>
                <li><a href="bookList.jsp"><i>📚</i> 图书管理</a></li>
                <li><a href="userList.jsp"><i>👥</i> 用户管理</a></li>
                <li><a href="borrowList.jsp"><i>📋</i> 借阅管理</a></li>
                <li><a href="seatManage.jsp"><i>💺</i> 座位管理</a></li>
                <li><a href="statistics.jsp" class="active"><i>📈</i> 统计分析</a></li>
                <li><a href="settings.jsp"><i>⚙️</i> 系统设置</a></li>
            </ul>
        </div>
        
        <!-- 主内容区 -->
        <div class="main-content">
            <div class="top-header">
                <div class="header-left">统计分析</div>
                <div class="header-right">
                    <div class="user-info">
                        <span>👤 ${sessionScope.user.name}</span>
                        <span>(${sessionScope.user.role == 1 ? '管理员' : '用户'})</span>
                    </div>
                    <a href="../logout" class="logout-btn">退出登录</a>
                </div>
            </div>
            
            <div class="page-content">
                <div class="page-header">
                    <h2>统计分析</h2>
                    <p>图书馆运营数据统计与分析</p>
                </div>
                
                <!-- 统计卡片 -->
                <div class="stats-cards">
                    <div class="stat-card">
                        <div class="stat-icon blue">📚</div>
                        <div class="stat-info">
                            <div class="stat-value">12,456</div>
                            <div class="stat-label">馆藏图书</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon green">👥</div>
                        <div class="stat-info">
                            <div class="stat-value">3,258</div>
                            <div class="stat-label">注册用户</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon orange">📖</div>
                        <div class="stat-info">
                            <div class="stat-value">1,856</div>
                            <div class="stat-label">本月借阅</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon purple">💺</div>
                        <div class="stat-info">
                            <div class="stat-value">4,521</div>
                            <div class="stat-label">座位预约</div>
                        </div>
                    </div>
                </div>
                
                <!-- 图表区域 -->
                <div class="chart-grid">
                    <!-- 借阅趋势 -->
                    <div class="chart-card">
                        <h3>📈 借阅趋势（近7天）</h3>
                        <div class="chart-container">
                            <canvas id="borrowTrendChart"></canvas>
                        </div>
                    </div>
                    
                    <!-- 分类占比 -->
                    <div class="chart-card">
                        <h3>📊 图书分类占比</h3>
                        <div class="chart-container">
                            <canvas id="categoryChart"></canvas>
                        </div>
                    </div>
                    
                    <!-- 热门图书 -->
                    <div class="chart-card chart-full">
                        <h3>🔥 热门图书借阅排行</h3>
                        <div class="chart-container">
                            <canvas id="hotBooksChart"></canvas>
                        </div>
                    </div>
                    
                    <!-- 用户活跃度 -->
                    <div class="chart-card">
                        <h3>👥 用户活跃度（本月）</h3>
                        <div class="chart-container">
                            <canvas id="userActiveChart"></canvas>
                        </div>
                    </div>
                    
                    <!-- 座位使用 -->
                    <div class="chart-card">
                        <h3>💺 楼层座位使用率</h3>
                        <div class="chart-container">
                            <canvas id="seatUsageChart"></canvas>
                        </div>
                    </div>
                </div>
                
                <!-- 热门图书表格 -->
                <div class="data-table">
                    <h3>📚 热门图书 TOP 10</h3>
                    <table>
                        <thead>
                            <tr>
                                <th>排名</th>
                                <th>书名</th>
                                <th>作者</th>
                                <th>分类</th>
                                <th>借阅次数</th>
                                <th>馆藏数量</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td><span class="rank rank-1">1</span></td>
                                <td>Java编程思想</td>
                                <td>Bruce Eckel</td>
                                <td>计算机科学</td>
                                <td>156</td>
                                <td>10</td>
                            </tr>
                            <tr>
                                <td><span class="rank rank-2">2</span></td>
                                <td>深入理解计算机系统</td>
                                <td>Randal E.Bryant</td>
                                <td>计算机科学</td>
                                <td>142</td>
                                <td>5</td>
                            </tr>
                            <tr>
                                <td><span class="rank rank-3">3</span></td>
                                <td>百年孤独</td>
                                <td>加西亚·马尔克斯</td>
                                <td>文学小说</td>
                                <td>128</td>
                                <td>15</td>
                            </tr>
                            <tr>
                                <td><span class="rank rank-other">4</span></td>
                                <td>算法导论</td>
                                <td>Thomas H.Cormen</td>
                                <td>计算机科学</td>
                                <td>115</td>
                                <td>8</td>
                            </tr>
                            <tr>
                                <td><span class="rank rank-other">5</span></td>
                                <td>经济学原理</td>
                                <td>曼昆</td>
                                <td>经济管理</td>
                                <td>98</td>
                                <td>12</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // 借阅趋势图
            const borrowCtx = document.getElementById('borrowTrendChart').getContext('2d');
            new Chart(borrowCtx, {
                type: 'line',
                data: {
                    labels: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
                    datasets: [{
                        label: '借阅数量',
                        data: [125, 158, 142, 186, 215, 268, 234],
                        borderColor: '#409eff',
                        backgroundColor: 'rgba(64, 158, 255, 0.1)',
                        fill: true,
                        tension: 0.4,
                        pointBackgroundColor: '#409eff',
                        pointRadius: 4
                    }, {
                        label: '归还数量',
                        data: [98, 132, 115, 156, 189, 225, 198],
                        borderColor: '#67c23a',
                        backgroundColor: 'rgba(103, 194, 58, 0.1)',
                        fill: true,
                        tension: 0.4,
                        pointBackgroundColor: '#67c23a',
                        pointRadius: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { position: 'top' }
                    }
                }
            });
            
            // 分类占比图
            const categoryCtx = document.getElementById('categoryChart').getContext('2d');
            new Chart(categoryCtx, {
                type: 'doughnut',
                data: {
                    labels: ['计算机科学', '文学小说', '经济管理', '自然科学', '工程技术', '其他'],
                    datasets: [{
                        data: [35, 25, 15, 10, 8, 7],
                        backgroundColor: [
                            '#409eff', '#67c23a', '#e6a23c', '#f56c6c', '#909399', '#bbdc00'
                        ]
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { position: 'right' }
                    }
                }
            });
            
            // 热门图书柱状图
            const hotBooksCtx = document.getElementById('hotBooksChart').getContext('2d');
            new Chart(hotBooksCtx, {
                type: 'bar',
                data: {
                    labels: ['Java编程思想', '深入理解计算机系统', '百年孤独', '算法导论', '经济学原理', '红楼梦', 'Python编程', '新概念英语'],
                    datasets: [{
                        label: '借阅次数',
                        data: [156, 142, 128, 115, 98, 87, 76, 65],
                        backgroundColor: 'rgba(64, 158, 255, 0.8)',
                        borderRadius: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false }
                    },
                    scales: {
                        y: { beginAtZero: true }
                    }
                }
            });
            
            // 用户活跃度
            const userActiveCtx = document.getElementById('userActiveChart').getContext('2d');
            new Chart(userActiveCtx, {
                type: 'polarArea',
                data: {
                    labels: ['借阅图书', '预约座位', '检索图书', '浏览页面'],
                    datasets: [{
                        data: [35, 28, 65, 82],
                        backgroundColor: [
                            'rgba(64, 158, 255, 0.7)',
                            'rgba(103, 194, 58, 0.7)',
                            'rgba(230, 162, 60, 0.7)',
                            'rgba(245, 108, 108, 0.7)'
                        ]
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false
                }
            });
            
            // 座位使用率
            const seatUsageCtx = document.getElementById('seatUsageChart').getContext('2d');
            new Chart(seatUsageCtx, {
                type: 'bar',
                data: {
                    labels: ['1楼', '2楼', '3楼', '4楼', '5楼'],
                    datasets: [{
                        label: '使用率',
                        data: [78, 85, 92, 72, 68],
                        backgroundColor: [
                            'rgba(64, 158, 255, 0.8)',
                            'rgba(103, 194, 58, 0.8)',
                            'rgba(230, 162, 60, 0.8)',
                            'rgba(245, 108, 108, 0.8)',
                            'rgba(144, 147, 153, 0.8)'
                        ],
                        borderRadius: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    indexAxis: 'y',
                    plugins: {
                        legend: { display: false }
                    },
                    scales: {
                        x: { max: 100 }
                    }
                }
            });
        });
    </script>
</body>
</html>
