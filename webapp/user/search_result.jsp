<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.library.model.User"%>
<%@ page import="com.library.service.BookService"%>
<%@ page import="com.library.model.BookCategory"%>
<%@ page import="java.util.List"%>
<%@ page import="com.library.model.Book"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    BookService bookService = new BookService();
    List<BookCategory> categories = bookService.getAllCategories();
    
    List<Book> books = (List<Book>) request.getAttribute("books");
    String keyword = (String) request.getAttribute("keyword");
    Integer categoryId = (Integer) request.getAttribute("categoryId");
    int currentPage = (Integer) request.getAttribute("currentPage");
    int totalPages = (Integer) request.getAttribute("totalPages");
    int totalCount = (Integer) request.getAttribute("totalCount");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>搜索结果 - 图书馆管理系统</title>
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
        
        .search-panel { background: white; border-radius: 10px; padding: 20px; margin-bottom: 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .search-form { display: flex; gap: 10px; margin-bottom: 20px; }
        .search-form select, .search-form input { padding: 10px 15px; border: 1px solid #ddd; border-radius: 5px; font-size: 14px; }
        .search-form input { flex: 1; }
        .search-form button { padding: 10px 20px; background: #3498db; border: none; border-radius: 5px; color: white; cursor: pointer; }
        
        .filter-tags { display: flex; gap: 10px; flex-wrap: wrap; }
        .filter-tag { padding: 5px 15px; border: 1px solid #ddd; border-radius: 20px; background: white; cursor: pointer; font-size: 14px; }
        .filter-tag:hover, .filter-tag.active { background: #3498db; color: white; border-color: #3498db; }
        
        .book-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; }
        .book-card { 
            background: white; 
            border-radius: 10px; 
            overflow: hidden; 
            box-shadow: 0 2px 5px rgba(0,0,0,0.05); 
            transition: transform 0.3s; 
            cursor: pointer; 
        }
        .book-card:hover { transform: translateY(-5px); box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
        .book-cover { 
            height: 180px; 
            background: #f0f0f0; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            font-size: 48px; 
        }
        .book-info { padding: 15px; }
        .book-title { 
            font-size: 16px; 
            font-weight: bold; 
            margin-bottom: 5px; 
            overflow: hidden; 
            text-overflow: ellipsis; 
            white-space: nowrap; 
        }
        .book-author { color: #666; font-size: 14px; margin-bottom: 5px; }
        .book-category { 
            display: inline-block; 
            padding: 2px 8px; 
            background: #e3f2fd; 
            color: #1976d2; 
            border-radius: 3px; 
            font-size: 12px; 
            margin-bottom: 10px; 
        }
        .book-status { font-size: 14px; }
        .book-status.available { color: #27ae60; }
        .book-status.borrowed { color: #e74c3c; }
        
        .pagination { 
            display: flex; 
            justify-content: center; 
            gap: 10px; 
            margin-top: 30px; 
        }
        .page-btn { 
            padding: 8px 15px; 
            border: 1px solid #ddd; 
            background: white; 
            border-radius: 5px; 
            cursor: pointer; 
            text-decoration: none; 
            color: #333; 
        }
        .page-btn:hover, .page-btn.active { 
            background: #3498db; 
            color: white; 
            border-color: #3498db; 
        }
        
        .empty-state { 
            text-align: center; 
            padding: 60px 20px; 
            color: #999; 
            font-size: 16px; 
        }
        .empty-state .icon { font-size: 64px; margin-bottom: 20px; }
        
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
                <a href="search.jsp" class="active">图书检索</a>
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
            <h2 class="page-title">🔍 搜索结果</h2>
            
            <div class="search-panel">
                <form class="search-form" action="<%= request.getContextPath() %>/searchBook" method="get">
                    <select name="categoryId">
                        <option value="">全部分类</option>
                        <% for (BookCategory cat : categories) { %>
                        <option value="<%= cat.getId() %>" <%= categoryId != null && categoryId.equals(cat.getId()) ? "selected" : "" %>><%= cat.getName() %></option>
                        <% } %>
                    </select>
                    <input type="text" name="keyword" placeholder="请输入搜索关键词..." value="<%= keyword != null ? keyword : "" %>">
                    <button type="submit">搜索</button>
                </form>
            </div>
            
            <% if (books != null && !books.isEmpty()) { %>
            <div class="book-grid">
                <% for (Book book : books) { %>
                <div class="book-card" onclick="location.href='book_detail.jsp?id=<%= book.getId() %>'">
                    <div class="book-cover">📕</div>
                    <div class="book-info">
                        <div class="book-title"><%= book.getTitle() %></div>
                        <div class="book-author"><%= book.getAuthor() %></div>
                        <span class="book-category"><%= book.getCategoryName() != null ? book.getCategoryName() : "未分类" %></span>
                        <div class="book-status <%= book.isAvailable() ? "available" : "borrowed" %>">
                            <%= book.isAvailable() ? "✓ 可借" : "✗ 已借出" %>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
            
            <div class="pagination">
                <% if (currentPage > 1) { %>
                <a href="<%= request.getContextPath() %>/searchBook?page=<%= currentPage - 1 %>&<%= keyword != null ? "keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8") + "&" : "" %><%= categoryId != null ? "categoryId=" + categoryId + "&" : "" %>
                    class="page-btn">上一页</a>
                <% } %>
                
                <% for (int i = 1; i <= totalPages; i++) { %>
                <a href="<%= request.getContextPath() %>/searchBook?page=<%= i %>&<%= keyword != null ? "keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8") + "&" : "" %><%= categoryId != null ? "categoryId=" + categoryId + "&" : "" %>
                    class="page-btn <%= i == currentPage ? "active" : "" %>"><%= i %></a>
                <% } %>
                
                <% if (currentPage < totalPages) { %>
                <a href="<%= request.getContextPath() %>/searchBook?page=<%= currentPage + 1 %>&<%= keyword != null ? "keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8") + "&" : "" %><%= categoryId != null ? "categoryId=" + categoryId + "&" : "" %>
                    class="page-btn">下一页</a>
                <% } %>
            </div>
            
            <% } else { %>
            <div class="empty-state">
                <div class="icon">📭</div>
                <p>没有找到相关图书</p>
                <p>请尝试其他关键词或分类</p>
            </div>
            <% } %>
        </div>
    </div>
    
    <div class="footer">
        <div class="container">
            <p>© 2024 图书馆管理系统 | 地址：XX市XX区XX路XX号 | 联系电话：123-4567890</p>
        </div>
    </div>
</body>
</html>