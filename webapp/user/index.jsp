<!-- user/index.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.library.model.User"%>
<%@ page import="com.library.service.BookService"%>
<%@ page import="com.library.model.Book"%>
<%@ page import="java.util.List"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    BookService bookService = new BookService();
    List<Book> newBooks = null;
    List<Book> hotBooks = null;
    List<Book> recommendBooks = null;
    try {
        newBooks = bookService.getNewBooks(4);
        hotBooks = bookService.getHotBooks(4);
        recommendBooks = bookService.getRecommendBooks(user.getId(), 4);
    } catch (Exception e) {
        e.printStackTrace();
    }
    if (newBooks == null || newBooks.isEmpty()) {
        newBooks = new java.util.ArrayList<Book>();
        for (int i = 0; i < 4; i++) {
            Book b = new Book();
            b.setId(i);
            b.setTitle("示例图书 " + (i + 1));
            b.setAuthor("作者 " + (i + 1));
            b.setStatus(1);
            newBooks.add(b);
        }
    }
    if (hotBooks == null || hotBooks.isEmpty()) {
        hotBooks = newBooks;
    }
    if (recommendBooks == null || recommendBooks.isEmpty()) {
        recommendBooks = newBooks;
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>图书馆管理系统 - 首页</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Microsoft YaHei', sans-serif; background: #f5f5f5; }
        
        /* 头部导航 */
        .header { background: #2c3e50; color: white; padding: 15px 0; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .container { width: 1200px; margin: 0 auto; }
        .header .container { display: flex; justify-content: space-between; align-items: center; }
        .logo { font-size: 24px; font-weight: bold; }
        .nav { display: flex; gap: 30px; }
        .nav a { color: white; text-decoration: none; font-size: 16px; transition: opacity 0.3s; }
        .nav a:hover { opacity: 0.8; }
        .user-info { display: flex; align-items: center; gap: 15px; }
        .user-name { color: #3498db; }
        .logout-btn { background: #e74c3c; padding: 5px 15px; border-radius: 5px; color: white; text-decoration: none; font-size: 14px; }
        
        /* 主内容区 */
        .main { padding: 30px 0; }
        
        /* 轮播图 */
        .carousel { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); height: 300px; border-radius: 10px; margin-bottom: 30px; display: flex; align-items: center; justify-content: center; color: white; font-size: 24px; }
        
        /* 快捷检索 */
        .search-box { background: white; border-radius: 10px; padding: 20px; margin-bottom: 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .search-title { font-size: 18px; font-weight: bold; margin-bottom: 15px; }
        .search-form { display: flex; gap: 10px; }
        .search-form input { flex: 1; padding: 12px 15px; border: 1px solid #ddd; border-radius: 5px; font-size: 16px; }
        .search-form button { padding: 12px 30px; background: #3498db; border: none; border-radius: 5px; color: white; font-size: 16px; cursor: pointer; }
        
        /* 图书区域 */
        .section { margin-bottom: 30px; }
        .section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .section-header h2 { font-size: 20px; }
        .more-link { color: #3498db; text-decoration: none; }
        .book-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; }
        .book-card { background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 5px rgba(0,0,0,0.05); transition: transform 0.3s; cursor: pointer; }
        .book-card:hover { transform: translateY(-5px); box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
        .book-cover { height: 180px; background: #f0f0f0; display: flex; align-items: center; justify-content: center; font-size: 48px; }
        .book-info { padding: 15px; }
        .book-title { font-size: 16px; font-weight: bold; margin-bottom: 5px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .book-author { color: #666; font-size: 14px; margin-bottom: 5px; }
        .book-status { font-size: 14px; color: #27ae60; }
        
        /* 功能入口 */
        .function-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-top: 20px; }
        .function-card { background: white; border-radius: 10px; padding: 30px; text-align: center; cursor: pointer; transition: all 0.3s; text-decoration: none; color: #333; display: block; }
        .function-card:hover { transform: translateY(-5px); box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
        .function-icon { font-size: 48px; margin-bottom: 15px; }
        .function-name { font-size: 16px; font-weight: bold; }
        
        /* 底部 */
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
                <a href="borrowing.jsp">我的借阅</a>
            </div>
            <div class="user-info">
                <span class="user-name">欢迎，<%= user.getName() %></span>
                <a href="<%= request.getContextPath() %>/logout" class="logout-btn">退出</a>
            </div>
        </div>
    </div>
    
    <div class="main">
        <div class="container">
            <div class="carousel">
                📖 欢迎使用图书馆管理系统 📖
            </div>
            
            <div class="search-box">
                <div class="search-title">🔍 图书检索</div>
                <form class="search-form" action="<%= request.getContextPath() %>/searchBook" method="get">
                    <input type="text" name="keyword" placeholder="请输入书名、作者或ISBN号" required>
                    <button type="submit">搜索</button>
                </form>
            </div>
            
            <div class="section">
                <div class="section-header">
                    <h2>📖 新书上架</h2>
                    <a href="search.jsp?type=new" class="more-link">更多 &gt;</a>
                </div>
                <div class="book-grid">
                    <% for (Book book : newBooks) { %>
                    <div class="book-card" onclick="location.href='book_detail.jsp?id=<%= book.getId() %>'">
                        <div class="book-cover">📕</div>
                        <div class="book-info">
                            <div class="book-title"><%= book.getTitle() %></div>
                            <div class="book-author"><%= book.getAuthor() %></div>
                            <div class="book-status"><%= book.isAvailable() ? "✓ 可借" : "✗ 已借出" %></div>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>
            
            <div class="section">
                <div class="section-header">
                    <h2>🔥 热门推荐</h2>
                    <a href="search.jsp?type=hot" class="more-link">更多 &gt;</a>
                </div>
                <div class="book-grid">
                    <% for (Book book : hotBooks) { %>
                    <div class="book-card" onclick="location.href='book_detail.jsp?id=<%= book.getId() %>'">
                        <div class="book-cover">📘</div>
                        <div class="book-info">
                            <div class="book-title"><%= book.getTitle() %></div>
                            <div class="book-author"><%= book.getAuthor() %></div>
                            <div class="book-status"><%= book.isAvailable() ? "✓ 可借" : "✗ 已借出" %></div>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>
            
            <div class="section">
                <div class="section-header">
                    <h2>💡 猜你喜欢</h2>
                </div>
                <div class="book-grid">
                    <% for (Book book : recommendBooks) { %>
                    <div class="book-card" onclick="location.href='book_detail.jsp?id=<%= book.getId() %>'">
                        <div class="book-cover">📙</div>
                        <div class="book-info">
                            <div class="book-title"><%= book.getTitle() %></div>
                            <div class="book-author"><%= book.getAuthor() %></div>
                            <div class="book-status"><%= book.isAvailable() ? "✓ 可借" : "✗ 已借出" %></div>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>
            
            <div class="section">
                <div class="section-header">
                    <h2>⚡ 快捷服务</h2>
                </div>
                <div class="function-grid">
                    <a href="search.jsp" class="function-card">
                        <div class="function-icon">🔍</div>
                        <div class="function-name">图书检索</div>
                    </a>
                    <a href="borrowing.jsp" class="function-card">
                        <div class="function-icon">📖</div>
                        <div class="function-name">我的借阅</div>
                    </a>
                    <a href="seat.jsp" class="function-card">
                        <div class="function-icon">💺</div>
                        <div class="function-name">座位预约</div>
                    </a>
                    <a href="<%= request.getContextPath() %>/profile?action=info" class="function-card">
                        <div class="function-icon">👤</div>
                        <div class="function-name">个人中心</div>
                    </a>
                </div>
            </div>
        </div>
    </div>
    
    <div class="footer">
        <div class="container">
            <p>© 2024 图书馆管理系统 | 地址：XX市XX区XX路XX号 | 联系电话：123-4567890</p>
        </div>
    </div>
</body>
</html>