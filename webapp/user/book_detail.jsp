<!-- user/book_detail.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.library.model.User"%>
<%@ page import="com.library.service.BookService"%>
<%@ page import="com.library.model.Book"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    String bookIdStr = request.getParameter("id");
    Book book = null;
    if (bookIdStr != null && !bookIdStr.isEmpty()) {
        try {
            Integer bookId = Integer.parseInt(bookIdStr);
            BookService bookService = new BookService();
            book = bookService.getBookDetail(bookId);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    if (book == null) {
        response.sendRedirect("search.jsp");
        return;
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>图书详情 - 图书馆管理系统</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Microsoft YaHei', sans-serif; background: #f5f5f5; }
        
        .header { background: #2c3e50; color: white; padding: 15px 0; }
        .container { width: 1200px; margin: 0 auto; }
        .header .container { display: flex; justify-content: space-between; align-items: center; }
        .logo { font-size: 24px; font-weight: bold; }
        .nav { display: flex; gap: 30px; }
        .nav a { color: white; text-decoration: none; }
        .nav a:hover { color: #3498db; }
        .user-info { display: flex; align-items: center; gap: 15px; }
        .logout-btn { background: #e74c3c; padding: 5px 15px; border-radius: 5px; color: white; text-decoration: none; }
        
        .main { padding: 30px 0; }
        .page-title { margin-bottom: 30px; color: #333; }
        
        .book-detail { background: white; border-radius: 10px; padding: 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); display: flex; gap: 40px; }
        .book-cover-large { 
            width: 200px; 
            height: 280px; 
            background: #f0f0f0; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            font-size: 100px; 
            border-radius: 10px;
            flex-shrink: 0;
        }
        .book-info { flex: 1; }
        .book-title { font-size: 28px; font-weight: bold; margin-bottom: 10px; color: #333; }
        .book-meta { display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px; margin: 20px 0; }
        .meta-item { display: flex; }
        .meta-label { width: 80px; color: #666; flex-shrink: 0; }
        .meta-value { color: #333; }
        
        .book-status { 
            display: inline-block; 
            padding: 8px 20px; 
            border-radius: 20px; 
            font-size: 16px; 
            font-weight: bold;
            margin-right: 15px;
        }
        .status-available { background: #d4edda; color: #155724; }
        .status-borrowed { background: #f8d7da; color: #721c24; }
        
        .action-buttons { margin-top: 30px; display: flex; gap: 15px; }
        .action-btn { 
            padding: 12px 40px; 
            border: none; 
            border-radius: 5px; 
            font-size: 16px; 
            cursor: pointer; 
            text-decoration: none;
            display: inline-block;
        }
        .btn-primary { background: #3498db; color: white; }
        .btn-primary:hover { background: #2980b9; }
        .btn-primary:disabled { background: #bdc3c7; cursor: not-allowed; }
        .btn-secondary { background: #ecf0f1; color: #333; }
        .btn-secondary:hover { background: #d5dbdb; }
        
        .book-description { margin-top: 30px; }
        .description-title { font-size: 18px; font-weight: bold; margin-bottom: 15px; color: #333; padding-bottom: 10px; border-bottom: 2px solid #3498db; display: inline-block; }
        .description-content { line-height: 1.8; color: #666; background: #fafafa; padding: 20px; border-radius: 5px; }
        
        .location-info { margin-top: 30px; background: #e8f4f8; padding: 20px; border-radius: 5px; }
        .location-title { font-weight: bold; color: #2980b9; margin-bottom: 10px; }
        .location-content { color: #333; }
        
        .back-link { 
            display: inline-block; 
            margin-bottom: 20px; 
            color: #3498db; 
            text-decoration: none; 
        }
        .back-link:hover { text-decoration: underline; }
        
        .toast {
            position: fixed;
            top: 100px;
            left: 50%;
            transform: translateX(-50%);
            padding: 12px 24px;
            border-radius: 5px;
            color: white;
            font-size: 14px;
            z-index: 1000;
            display: none;
        }
        .toast.success { background: #27ae60; }
        .toast.error { background: #e74c3c; }
        
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
                <a href="<%= request.getContextPath() %>/logout" class="logout-btn">退出</a>
            </div>
        </div>
    </div>
    
    <div class="main">
        <div class="container">
            <a href="javascript:history.back()" class="back-link">← 返回上一页</a>
            
            <div class="book-detail">
                <div class="book-cover-large">📕</div>
                <div class="book-info">
                    <h1 class="book-title"><%= book.getTitle() %></h1>
                    
                    <div class="book-meta">
                        <div class="meta-item">
                            <span class="meta-label">作者：</span>
                            <span class="meta-value"><%= book.getAuthor() != null ? book.getAuthor() : "-" %></span>
                        </div>
                        <div class="meta-item">
                            <span class="meta-label">出版社：</span>
                            <span class="meta-value"><%= book.getPublisher() != null ? book.getPublisher() : "-" %></span>
                        </div>
                        <div class="meta-item">
                            <span class="meta-label">ISBN：</span>
                            <span class="meta-value"><%= book.getIsbn() != null ? book.getIsbn() : "-" %></span>
                        </div>
                        <div class="meta-item">
                            <span class="meta-label">分类：</span>
                            <span class="meta-value"><%= book.getCategoryName() != null ? book.getCategoryName() : "-" %></span>
                        </div>
                        <div class="meta-item">
                            <span class="meta-label">出版日期：</span>
                            <span class="meta-value"><%= book.getPublishDate() != null ? sdf.format(book.getPublishDate()) : "-" %></span>
                        </div>
                        <div class="meta-item">
                            <span class="meta-label">位置：</span>
                            <span class="meta-value"><%= book.getLocation() != null ? book.getLocation() : "-" %></span>
                        </div>
                    </div>
                    
                    <div>
                        <% if (book.isAvailable()) { %>
                        <span class="book-status status-available">✓ 可借阅</span>
                        <% } else { %>
                        <span class="book-status status-borrowed">✗ 已借出</span>
                        <% } %>
                        <span style="color: #666;">馆藏：<%= book.getTotalCount() %> 册 | 可借：<%= book.getAvailableCount() %> 册</span>
                    </div>
                    
                    <div class="action-buttons">
                        <% if (book.isAvailable()) { %>
                        <button class="action-btn btn-primary" onclick="borrowBook(<%= book.getId() %>)">立即借阅</button>
                        <button class="action-btn btn-secondary" onclick="reserveBook(<%= book.getId() %>)">预约登记</button>
                        <% } else { %>
                        <button class="action-btn btn-primary" disabled>已借出</button>
                        <button class="action-btn btn-secondary" onclick="reserveBook(<%= book.getId() %>)">预约排队</button>
                        <% } %>
                    </div>
                    
                    <div class="location-info">
                        <div class="location-title">📍 馆藏位置</div>
                        <div class="location-content"><%= book.getLocation() != null ? book.getLocation() : "暂无位置信息" %></div>
                    </div>
                </div>
            </div>
            
            <div class="book-description">
                <h3 class="description-title">内容简介</h3>
                <div class="description-content">
                    <%= book.getDescription() != null && !book.getDescription().isEmpty() ? book.getDescription() : "暂无内容简介" %>
                </div>
            </div>
        </div>
    </div>
    
    <div id="toast" class="toast"></div>
    
    <div class="footer">
        <div class="container">
            <p>© 2024 图书馆管理系统 | 地址：XX市XX区XX路XX号 | 联系电话：123-4567890</p>
        </div>
    </div>
    
    <script>
        function borrowBook(bookId) {
            if (!confirm('确定要借阅这本书吗？')) return;
            
            fetch('<%= request.getContextPath() %>/borrowBook', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'bookId=' + bookId
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showToast('借阅成功！', 'success');
                    setTimeout(() => location.reload(), 1500);
                } else {
                    showToast(data.message || '借阅失败', 'error');
                }
            })
            .catch(error => {
                showToast('系统错误，请稍后重试', 'error');
            });
        }
        
        function reserveBook(bookId) {
            if (!confirm('确定要预约登记这本书吗？')) return;
            
            fetch('<%= request.getContextPath() %>/reserveBook', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'bookId=' + bookId
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showToast('预约成功！请等待通知', 'success');
                } else {
                    showToast(data.message || '预约失败', 'error');
                }
            })
            .catch(error => {
                showToast('系统错误，请稍后重试', 'error');
            });
        }
        
        function showToast(message, type) {
            const toast = document.getElementById('toast');
            toast.textContent = message;
            toast.className = 'toast ' + type;
            toast.style.display = 'block';
            
            setTimeout(() => {
                toast.style.display = 'none';
            }, 3000);
        }
    </script>
</body>
</html>
