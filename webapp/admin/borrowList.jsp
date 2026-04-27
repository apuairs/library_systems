<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.library.model.User"%>
<%@ page import="com.library.model.BorrowRecord"%>
<%@ page import="com.library.service.BorrowService"%>
<%@ page import="java.util.List"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRole() != 1) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    BorrowService borrowService = new BorrowService();
    List<BorrowRecord> records = borrowService.getAllBorrowRecords();
    
    int borrowing = 0;
    int returned = 0;
    int overdue = 0;
    
    if (records != null) {
        for (BorrowRecord r : records) {
            if (r.getStatus() == 0) {
                borrowing++;
            } else if (r.getStatus() == 1) {
                returned++;
            } else if (r.getStatus() == 2) {
                overdue++;
            }
        }
    }
    
    int total = records != null ? records.size() : 0;
    double returnRate = total > 0 ? (double)returned / total * 100 : 0;
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>借阅管理 - 图书馆管理系统</title>
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
        
        .toolbar { background: white; padding: 15px 20px; border-radius: 4px; margin-bottom: 20px; display: flex; gap: 10px; align-items: center; flex-wrap: wrap; }
        .search-input { padding: 8px 12px; border: 1px solid #dcdfe6; border-radius: 4px; width: 200px; font-size: 14px; }
        .search-input:focus { outline: none; border-color: #409eff; }
        .btn { padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; font-size: 14px; transition: all 0.2s; }
        .btn-primary { background: #409eff; color: white; }
        .btn-primary:hover { background: #66b1ff; }
        .btn-warning { background: #e6a23c; color: white; }
        .btn-warning:hover { background: #ebb563; }
        
        .data-table { background: white; border-radius: 4px; overflow: hidden; }
        .data-table table { width: 100%; border-collapse: collapse; }
        .data-table th, .data-table td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #ebeef5; }
        .data-table th { background: #f5f7fa; color: #909399; font-weight: 500; font-size: 14px; }
        .data-table td { color: #606266; font-size: 14px; }
        .data-table tr:hover td { background: #f5f7fa; }
        .action-btns { display: flex; gap: 5px; }
        .action-btns .btn { padding: 4px 8px; font-size: 12px; }
        
        .status-tag { padding: 2px 8px; border-radius: 4px; font-size: 12px; }
        .status-borrowing { background: #eef2ff; color: #409eff; }
        .status-returned { background: #f0f9ff; color: #67c23a; }
        .status-overdue { background: #fef0f0; color: #f56c6c; }
        .status-renewed { background: #fdf6ec; color: #e6a23c; }
        
        .pagination { display: flex; justify-content: flex-end; align-items: center; gap: 10px; padding: 15px 20px; background: white; border-top: 1px solid #ebeef5; }
        .pagination span { color: #909399; font-size: 14px; }
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
                <li><a href="borrowList.jsp" class="active">📋 借阅管理</a></li>
                <li><a href="seatManage.jsp">💺 座位管理</a></li>
                <li><a href="statistics.jsp">📈 统计分析</a></li>
                <li><a href="settings.jsp">⚙️ 系统设置</a></li>
            </ul>
        </div>
        
        <div class="main-content">
            <div class="top-header">
                <div class="header-left">借阅管理</div>
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
                    <h2>借阅管理</h2>
                    <p>查看和管理所有图书借阅记录</p>
                </div>
                
                <div class="stats-cards">
                    <div class="stat-card">
                        <div class="stat-value"><%= borrowing %></div>
                        <div class="stat-label">借阅中</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value"><%= returned %></div>
                        <div class="stat-label">已归还</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value" style="color: #f56c6c;"><%= overdue %></div>
                        <div class="stat-label">已逾期</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value" style="color: #67c23a;"><%= String.format("%.1f", returnRate) %>%</div>
                        <div class="stat-label">归还率</div>
                    </div>
                </div>
                
                <div class="toolbar">
                    <input type="text" class="search-input" placeholder="搜索书名/用户名..." id="searchKeyword">
                    <select class="search-input" id="borrowStatus">
                        <option value="">全部状态</option>
                        <option value="0">借阅中</option>
                        <option value="1">已归还</option>
                        <option value="2">已逾期</option>
                    </select>
                    <button class="btn btn-primary" onclick="filterRecords()">🔍 搜索</button>
                    <button class="btn btn-warning" onclick="resetFilter()">🔄 重置</button>
                </div>
                
                <div class="data-table">
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>书名</th>
                                <th>借阅用户</th>
                                <th>借阅日期</th>
                                <th>应还日期</th>
                                <th>实际归还</th>
                                <th>续借次数</th>
                                <th>状态</th>
                                <th>操作</th>
                            </tr>
                        </thead>
                        <tbody id="borrowTableBody">
                            <%
                            if (records != null && !records.isEmpty()) {
                                for (BorrowRecord r : records) {
                                    String statusClass = "";
                                    String statusText = "";
                                    switch (r.getStatus()) {
                                        case 0: statusClass = "status-borrowing"; statusText = "借阅中"; break;
                                        case 1: statusClass = "status-returned"; statusText = "已归还"; break;
                                        case 2: statusClass = "status-overdue"; statusText = "已逾期"; break;
                                        case 3: statusClass = "status-renewed"; statusText = "已续借"; break;
                                    }
                            %>
                            <tr data-status="<%= r.getStatus() %>">
                                <td><%= r.getId() %></td>
                                <td><%= r.getBookTitle() != null ? r.getBookTitle() : "未知" %></td>
                                <td><%= r.getUserName() != null ? r.getUserName() : "未知" %></td>
                                <td><%= r.getBorrowTime() != null ? sdf.format(r.getBorrowTime()) : "-" %></td>
                                <td><%= r.getDueTime() != null ? sdf.format(r.getDueTime()) : "-" %></td>
                                <td><%= r.getReturnTime() != null ? sdf.format(r.getReturnTime()) : "-" %></td>
                                <td><%= r.getRenewCount() != null ? r.getRenewCount() : 0 %></td>
                                <td><span class="status-tag <%= statusClass %>"><%= statusText %></span></td>
                                <td>
                                    <div class="action-btns">
                                        <button class="btn btn-primary" onclick="viewDetail(<%= r.getId() %>)">详情</button>
                                        <% if (r.getStatus() == 0 || r.getStatus() == 2) { %>
                                        <button class="btn btn-warning" onclick="sendReminder(<%= r.getId() %>)">催还</button>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <%
                                }
                            } else {
                            %>
                            <tr><td colspan="9" style="text-align: center; padding: 30px; color: #909399;">暂无借阅记录</td></tr>
                            <%
                            }
                            %>
                        </tbody>
                    </table>
                    
                    <div class="pagination">
                        <span>共 <%= total %> 条记录</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        function filterRecords() {
            var keyword = document.getElementById('searchKeyword').value.toLowerCase();
            var status = document.getElementById('borrowStatus').value;
            var rows = document.querySelectorAll('#borrowTableBody tr');
            
            rows.forEach(function(row) {
                var bookName = row.cells[1] ? row.cells[1].textContent.toLowerCase() : '';
                var userName = row.cells[2] ? row.cells[2].textContent.toLowerCase() : '';
                var rowStatus = row.getAttribute('data-status');
                
                var matchKeyword = !keyword || bookName.includes(keyword) || userName.includes(keyword);
                var matchStatus = !status || rowStatus === status;
                
                row.style.display = (matchKeyword && matchStatus) ? '' : 'none';
            });
        }
        
        function resetFilter() {
            document.getElementById('searchKeyword').value = '';
            document.getElementById('borrowStatus').value = '';
            var rows = document.querySelectorAll('#borrowTableBody tr');
            rows.forEach(function(row) {
                row.style.display = '';
            });
        }
        
        function viewDetail(id) {
            alert('查看借阅详情 - 记录ID: ' + id);
        }
        
        function sendReminder(id) {
            if (confirm('确定要发送催还通知吗？')) {
                alert('催还通知已发送！记录ID: ' + id);
            }
        }
    </script>
</body>
</html>
