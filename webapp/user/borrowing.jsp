<!-- user/borrowing.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.library.model.User"%>
<%@ page import="com.library.service.BorrowService"%>
<%@ page import="com.library.model.BorrowRecord"%>
<%@ page import="java.util.List"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    BorrowService borrowService = new BorrowService();
    List<BorrowRecord> currentBorrowing = borrowService.getCurrentBorrowing(user.getId());
    List<BorrowRecord> borrowHistory = borrowService.getBorrowHistory(user.getId());
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的借阅 - 图书馆管理系统</title>
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
        
        .tabs { display: flex; gap: 10px; margin-bottom: 20px; border-bottom: 2px solid #ddd; }
        .tab { padding: 10px 20px; cursor: pointer; border: none; background: none; font-size: 16px; }
        .tab.active { color: #3498db; border-bottom: 2px solid #3498db; margin-bottom: -2px; }
        
        .tab-content { display: none; }
        .tab-content.active { display: block; }
        
        .book-table { width: 100%; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .book-table th, .book-table td { padding: 15px; text-align: left; border-bottom: 1px solid #eee; }
        .book-table th { background: #f8f9fa; font-weight: bold; color: #555; }
        .book-table tr:hover { background: #fafafa; }
        
        .status-borrow { color: #27ae60; }
        .status-overdue { color: #e74c3c; font-weight: bold; }
        .status-returned { color: #95a5a6; }
        
        .btn { padding: 5px 15px; border: none; border-radius: 5px; cursor: pointer; font-size: 14px; }
        .btn-primary { background: #3498db; color: white; }
        .btn-warning { background: #f39c12; color: white; }
        .btn-danger { background: #e74c3c; color: white; }
        
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
                <a href="mySeats.jsp">我的预约</a>
                <a href="borrowing.jsp" class="active">我的借阅</a>
            </div>
            <div class="user-info">
                <span>欢迎，<%= user.getName() %></span>
                <a href="<%= request.getContextPath() %>/logout" class="logout-btn">退出</a>
            </div>
        </div>
    </div>
    
    <div class="main">
        <div class="container">
            <h2 class="page-title">📖 我的借阅</h2>
            
            <div class="tabs">
                <button class="tab active" onclick="showTab('current', this)">当前借阅 (<%= currentBorrowing.size() %>)</button>
                <button class="tab" onclick="showTab('history', this)">借阅历史 (<%= borrowHistory.size() %>)</button>
            </div>
            
            <div id="current" class="tab-content active">
                <% if (currentBorrowing.isEmpty()) { %>
                <div class="empty-msg">暂无借阅图书</div>
                <% } else { %>
                <table class="book-table">
                    <thead>
                        <tr>
                            <th>书名</th>
                            <th>ISBN</th>
                            <th>借书日期</th>
                            <th>应还日期</th>
                            <th>状态</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (BorrowRecord record : currentBorrowing) { %>
                        <tr>
                            <td><%= record.getBookTitle() %></td>
                            <td><%= record.getBookIsbn() %></td>
                            <td><%= sdf.format(record.getBorrowTime()) %></td>
                            <td class="<%= record.isOverdue() ? "status-overdue" : "" %>">
                                <%= sdf.format(record.getDueTime()) %>
                                <% if (record.isOverdue()) { %>
                                (逾期<%= record.getOverdueDays() %>天)
                                <% } %>
                            </td>
                            <td>
                                <% if (record.isOverdue()) { %>
                                <span class="status-overdue">逾期</span>
                                <% } else { %>
                                <span class="status-borrow">借出中</span>
                                <% } %>
                            </td>
                            <td>
                                <% if (!record.isOverdue() && record.getRenewCount() < 1) { %>
                                <form action="<%= request.getContextPath() %>/renewBook" method="post" style="display:inline;">
                                    <input type="hidden" name="recordId" value="<%= record.getId() %>">
                                    <button type="submit" class="btn btn-primary">续借</button>
                                </form>
                                <% } %>
                                <form action="<%= request.getContextPath() %>/returnBook" method="post" style="display:inline;">
                                    <input type="hidden" name="recordId" value="<%= record.getId() %>">
                                    <input type="hidden" name="from" value="user">
                                    <button type="submit" class="btn btn-warning">还书</button>
                                </form>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } %>
            </div>
            
            <div id="history" class="tab-content">
                <% if (borrowHistory.isEmpty()) { %>
                <div class="empty-msg">暂无借阅历史</div>
                <% } else { %>
                <table class="book-table">
                    <thead>
                        <tr>
                            <th>书名</th>
                            <th>ISBN</th>
                            <th>借书日期</th>
                            <th>还书日期</th>
                            <th>状态</th>
                            <th>罚款</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (BorrowRecord record : borrowHistory) { %>
                        <tr>
                            <td><%= record.getBookTitle() %></td>
                            <td><%= record.getBookIsbn() %></td>
                            <td><%= sdf.format(record.getBorrowTime()) %></td>
                            <td><%= record.getReturnTime() != null ? sdf.format(record.getReturnTime()) : "-" %></td>
                            <td><span class="status-returned">已归还</span></td>
                            <td><%= record.getFineAmount() != null && record.getFineAmount() > 0 ? "¥" + record.getFineAmount() : "-" %></td>
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
    
    <script>
        function showTab(tabName, button) {
            document.querySelectorAll('.tab-content').forEach(tab => {
                tab.classList.remove('active');
            });
            document.querySelectorAll('.tab').forEach(btn => {
                btn.classList.remove('active');
            });
            document.getElementById(tabName).classList.add('active');
            button.classList.add('active');
        }
    </script>
</body>
</html>