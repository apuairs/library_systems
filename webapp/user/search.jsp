<!-- user/search.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.library.model.User"%>
<%@ page import="com.library.service.BookService"%>
<%@ page import="com.library.model.BookCategory"%>
<%@ page import="java.util.List"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    BookService bookService = new BookService();
    List<BookCategory> categories = bookService.getAllCategories();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>图书检索 - 图书馆管理系统</title>
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
        .logout-btn { background: #e74c3c; padding: 5px 15px; border-radius: 5px; color: white; text-decoration: none; }
        
        .main { padding: 30px 0; }
        .page-title { margin-bottom: 30px; color: #333; }
        
        .search-panel { background: white; border-radius: 10px; padding: 20px; margin-bottom: 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .search-form { display: flex; gap: 10px; margin-bottom: 20px; }
        .search-form input, .search-form select { 
            padding: 12px 15px; 
            border: 1px solid #ddd; 
            border-radius: 5px; 
            font-size: 14px; 
        }
        .search-form input[type="text"] { flex: 1; min-width: 200px; }
        .search-form button { 
            padding: 12px 30px; 
            background: #3498db; 
            border: none; 
            border-radius: 5px; 
            color: white; 
            font-size: 16px; 
            cursor: pointer; 
        }
        .search-form button:hover { background: #2980b9; }
        
        .filter-tags { display: flex; gap: 10px; flex-wrap: wrap; }
        .filter-tag { 
            padding: 6px 15px; 
            background: #f0f0f0; 
            border-radius: 20px; 
            cursor: pointer; 
            font-size: 14px;
            transition: all 0.3s;
        }
        .filter-tag:hover, .filter-tag.active { 
            background: #3498db; 
            color: white; 
        }
        
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
                <a href="mySeats.jsp">我的预约</a>
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
            <h2 class="page-title">🔍 图书检索</h2>
            
            <div class="search-panel">
                <form class="search-form" id="searchForm">
                    <select id="categoryId" name="categoryId">
                        <option value="">全部分类</option>
                        <% for (BookCategory cat : categories) { %>
                        <option value="<%= cat.getId() %>"><%= cat.getName() %></option>
                        <% } %>
                    </select>
                    <select id="searchType" name="type">
                        <option value="">全部类型</option>
                        <option value="title">书名</option>
                        <option value="author">作者</option>
                        <option value="isbn">ISBN</option>
                    </select>
                    <input type="text" id="keyword" name="keyword" placeholder="请输入搜索关键词...">
                    <button type="submit">搜索</button>
                </form>
                
                <div class="filter-tags">
                    <span class="filter-tag active" data-category="">全部</span>
                    <% for (BookCategory cat : categories) { %>
                    <span class="filter-tag" data-category="<%= cat.getId() %>"><%= cat.getName() %></span>
                    <% } %>
                </div>
            </div>
            
            <div id="bookList" class="book-grid">
                <!-- 图书列表将通过JS动态加载 -->
            </div>
            
            <div id="pagination" class="pagination">
                <!-- 分页将通过JS动态加载 -->
            </div>
        </div>
    </div>
    
    <div class="footer">
        <div class="container">
            <p>© 2024 图书馆管理系统 | 地址：XX市XX区XX路XX号 | 联系电话：123-4567890</p>
        </div>
    </div>
    
    <script>
        let currentPage = 1;
        let currentKeyword = '';
        let currentCategory = '';
        let currentType = '';
        
        document.addEventListener('DOMContentLoaded', function() {
            searchBooks(1);
            
            document.getElementById('searchForm').addEventListener('submit', function(e) {
                e.preventDefault();
                currentKeyword = document.getElementById('keyword').value;
                currentCategory = document.getElementById('categoryId').value;
                currentType = document.getElementById('searchType').value;
                searchBooks(1);
            });
            
            document.querySelectorAll('.filter-tag').forEach(function(tag) {
                tag.addEventListener('click', function() {
                    document.querySelectorAll('.filter-tag').forEach(t => t.classList.remove('active'));
                    this.classList.add('active');
                    currentCategory = this.dataset.category || '';
                    document.getElementById('categoryId').value = currentCategory;
                    searchBooks(1);
                });
            });
        });
        
        function searchBooks(page) {
            currentPage = page;
            
            let url = '<%= request.getContextPath() %>/searchBook?page=' + page;
            if (currentKeyword) url += '&keyword=' + encodeURIComponent(currentKeyword);
            if (currentCategory) url += '&categoryId=' + currentCategory;
            if (currentType) url += '&type=' + currentType;
            
            fetch(url, {
                headers: {
                    'Accept': 'application/json'
                }
            })
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    renderBooks(data.books || data);
                    renderPagination(data.totalPages || 1, data.currentPage || 1);
                })
                .catch(error => {
                    console.error('Error:', error);
                    renderBooks([]);
                });
        }
        
        function renderBooks(books) {
            const container = document.getElementById('bookList');
            
            if (!books || books.length === 0) {
                container.innerHTML = '<div class="empty-state"><div class="icon">📚</div><p>暂无图书数据</p></div>';
                return;
            }
            
            container.innerHTML = books.map(book => {
                const status = book.availableCount && book.availableCount > 0 ? 'available' : 'borrowed';
                const statusText = book.availableCount && book.availableCount > 0 ? '✓ 可借' : '✗ 已借出';
                const category = book.categoryName || '-';
                
                return '<div class="book-card" onclick="location.href=' + "'book_detail.jsp?id=" + book.id + "'" + '">' +
                    '<div class="book-cover">📕</div>' +
                    '<div class="book-info">' +
                    '<div class="book-title">' + (book.title || '-') + '</div>' +
                    '<div class="book-author">' + (book.author || '-') + '</div>' +
                    '<span class="book-category">' + category + '</span>' +
                    '<div class="book-status ' + status + '">' + statusText + '</div>' +
                    '</div></div>';
            }).join('');
        }
        
        function renderPagination(totalPages, currentPageNum) {
            const container = document.getElementById('pagination');
            let html = '';
            
            if (currentPageNum > 1) {
                html += '<a href="javascript:void(0)" class="page-btn" onclick="searchBooks(' + (currentPageNum - 1) + ')">上一页</a>';
            }
            
            for (let i = 1; i <= Math.min(totalPages, 10); i++) {
                const active = i === currentPageNum ? 'active' : '';
                html += '<a href="javascript:void(0)" class="page-btn ' + active + '" onclick="searchBooks(' + i + ')">' + i + '</a>';
            }
            
            if (currentPageNum < totalPages) {
                html += '<a href="javascript:void(0)" class="page-btn" onclick="searchBooks(' + (currentPageNum + 1) + ')">下一页</a>';
            }
            
            container.innerHTML = html;
        }
    </script>
</body>
</html>
