<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>图书管理 - 图书馆管理系统</title>
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
        
        /* 工具栏 */
        .toolbar { background: white; padding: 15px 20px; border-radius: 4px; margin-bottom: 20px; display: flex; gap: 10px; align-items: center; flex-wrap: wrap; }
        .search-input { padding: 8px 12px; border: 1px solid #dcdfe6; border-radius: 4px; width: 200px; font-size: 14px; }
        .search-input:focus { outline: none; border-color: #409eff; }
        .btn { padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; font-size: 14px; transition: all 0.2s; }
        .btn-primary { background: #409eff; color: white; }
        .btn-primary:hover { background: #66b1ff; }
        .btn-success { background: #67c23a; color: white; }
        .btn-success:hover { background: #85ce61; }
        .btn-warning { background: #e6a23c; color: white; }
        .btn-warning:hover { background: #ebb563; }
        .btn-danger { background: #f56c6c; color: white; }
        .btn-danger:hover { background: #f78989; }
        
        /* 表格 */
        .data-table { background: white; border-radius: 4px; overflow: hidden; }
        .data-table table { width: 100%; border-collapse: collapse; }
        .data-table th, .data-table td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #ebeef5; }
        .data-table th { background: #f5f7fa; color: #909399; font-weight: 500; font-size: 14px; }
        .data-table td { color: #606266; font-size: 14px; }
        .data-table tr:hover td { background: #f5f7fa; }
        .action-btns { display: flex; gap: 5px; }
        .action-btns .btn { padding: 4px 8px; font-size: 12px; }
        
        /* 状态标签 */
        .status-tag { padding: 2px 8px; border-radius: 4px; font-size: 12px; }
        .status-available { background: #f0f9ff; color: #67c23a; }
        .status-borrowed { background: #fef0f0; color: #f56c6c; }
        
        /* 分页 */
        .pagination { display: flex; justify-content: flex-end; align-items: center; gap: 10px; padding: 15px 20px; background: white; border-top: 1px solid #ebeef5; }
        .pagination span { color: #909399; font-size: 14px; }
        .page-btn { padding: 5px 10px; border: 1px solid #dcdfe6; background: white; border-radius: 4px; cursor: pointer; font-size: 14px; color: #606266; }
        .page-btn:hover { border-color: #409eff; color: #409eff; }
        .page-btn.active { background: #409eff; color: white; border-color: #409eff; }
        
        /* 弹窗 */
        .modal-overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); display: none; align-items: center; justify-content: center; z-index: 1000; }
        .modal-overlay.show { display: flex; }
        .modal { background: white; border-radius: 8px; width: 500px; max-width: 90%; max-height: 90vh; overflow-y: auto; }
        .modal-header { padding: 15px 20px; border-bottom: 1px solid #ebeef5; display: flex; justify-content: space-between; align-items: center; }
        .modal-header h3 { font-size: 16px; color: #303133; }
        .modal-close { background: none; border: none; font-size: 20px; cursor: pointer; color: #909399; }
        .modal-body { padding: 20px; }
        .modal-footer { padding: 15px 20px; border-top: 1px solid #ebeef5; display: flex; justify-content: flex-end; gap: 10px; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; color: #606266; font-size: 14px; }
        .form-group input, .form-group select, .form-group textarea { width: 100%; padding: 8px 12px; border: 1px solid #dcdfe6; border-radius: 4px; font-size: 14px; }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus { outline: none; border-color: #409eff; }
        .form-row { display: flex; gap: 15px; }
        .form-row .form-group { flex: 1; }
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
                <li><a href="bookList.jsp" class="active"><i>📚</i> 图书管理</a></li>
                <li><a href="userList.jsp"><i>👥</i> 用户管理</a></li>
                <li><a href="borrowList.jsp"><i>📋</i> 借阅管理</a></li>
                <li><a href="seatManage.jsp"><i>💺</i> 座位管理</a></li>
                <li><a href="statistics.jsp"><i>📈</i> 统计分析</a></li>
                <li><a href="settings.jsp"><i>⚙️</i> 系统设置</a></li>
            </ul>
        </div>
        
        <!-- 主内容区 -->
        <div class="main-content">
            <div class="top-header">
                <div class="header-left">图书管理</div>
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
                    <h2>图书管理</h2>
                    <p>管理图书馆的所有图书信息</p>
                </div>
                
                <!-- 工具栏 -->
                <div class="toolbar">
                    <input type="text" class="search-input" placeholder="搜索书名/作者/ISBN..." id="searchKeyword">
                    <select class="search-input" id="categoryId">
                        <option value="">全部分类</option>
                    </select>
                    <button class="btn btn-primary" onclick="searchBooks()"><i>🔍</i> 搜索</button>
                    <button class="btn btn-success" onclick="openAddModal()"><i>➕</i> 添加图书</button>
                    <button class="btn btn-warning" onclick="refreshTable()"><i>🔄</i> 刷新</button>
                </div>
                
                <!-- 数据表格 -->
                <div class="data-table">
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>ISBN</th>
                                <th>书名</th>
                                <th>作者</th>
                                <th>分类</th>
                                <th>出版社</th>
                                <th>价格</th>
                                <th>总数/可借</th>
                                <th>位置</th>
                                <th>操作</th>
                            </tr>
                        </thead>
                        <tbody id="bookTableBody">
                            <tr><td colspan="10" style="text-align: center; padding: 30px; color: #909399;">加载中...</td></tr>
                        </tbody>
                    </table>
                    
                    <!-- 分页 -->
                    <div class="pagination">
                        <span id="pageInfo">共 0 条记录</span>
                        <div id="pageButtons">
                            <button class="page-btn active">1</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- 添加/编辑弹窗 -->
    <div class="modal-overlay" id="bookModal">
        <div class="modal">
            <div class="modal-header">
                <h3 id="modalTitle">添加图书</h3>
                <button class="modal-close" onclick="closeModal()">&times;</button>
            </div>
            <div class="modal-body">
                <form id="bookForm">
                    <input type="hidden" id="bookId">
                    <div class="form-group">
                        <label>ISBN *</label>
                        <input type="text" id="isbn" required placeholder="请输入ISBN号">
                    </div>
                    <div class="form-group">
                        <label>书名 *</label>
                        <input type="text" id="name" required placeholder="请输入书名">
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>作者</label>
                            <input type="text" id="author" placeholder="请输入作者">
                        </div>
                        <div class="form-group">
                            <label>分类</label>
                            <select id="bookCategoryId">
                                <option value="">请选择分类</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>出版社</label>
                            <input type="text" id="publisher" placeholder="请输入出版社">
                        </div>
                        <div class="form-group">
                            <label>价格</label>
                            <input type="number" step="0.01" id="price" placeholder="请输入价格">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>数量</label>
                            <input type="number" id="quantity" value="1" min="1" placeholder="请输入数量">
                        </div>
                        <div class="form-group">
                            <label>位置</label>
                            <input type="text" id="location" placeholder="如：A区-01架-01层">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>内容简介</label>
                        <textarea id="description" rows="3" placeholder="请输入内容简介"></textarea>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button class="btn" onclick="closeModal()">取消</button>
                <button class="btn btn-primary" onclick="saveBook()">保存</button>
            </div>
        </div>
    </div>
    
    <script>
        // 页面加载完成后初始化
        document.addEventListener('DOMContentLoaded', function() {
            loadCategories();
            loadBooks();
        });
        
        // 加载分类列表
        function loadCategories() {
            // 模拟数据，实际应该从API获取
            const categories = [
                {id: 1, name: '文学小说'},
                {id: 2, name: '计算机科学'},
                {id: 3, name: '经济管理'},
                {id: 4, name: '外语学习'},
                {id: 5, name: '自然科学'}
            ];
            
            const categorySelect = document.getElementById('categoryId');
            const bookCategorySelect = document.getElementById('bookCategoryId');
            
            categories.forEach(cat => {
                categorySelect.innerHTML += '<option value="' + cat.id + '">' + cat.name + '</option>';
                bookCategorySelect.innerHTML += '<option value="' + cat.id + '">' + cat.name + '</option>';
            });
        }
        
        // 加载图书列表
        function loadBooks(page = 1) {
            // 模拟数据
            const mockBooks = [
                {id: 1, isbn: '9787115428029', name: 'Java编程思想', author: 'Bruce Eckel', categoryName: '计算机科学', publisher: '机械工业出版社', price: 108.00, quantity: 10, available: 10, location: 'A区-01架-02层'},
                {id: 2, isbn: '9787302275167', name: '深入理解计算机系统', author: 'Randal E.Bryant', categoryName: '计算机科学', publisher: '清华大学出版社', price: 139.00, quantity: 5, available: 5, location: 'A区-01架-03层'},
                {id: 3, isbn: '9787020104235', name: '百年孤独', author: '加西亚·马尔克斯', categoryName: '文学小说', publisher: '人民文学出版社', price: 39.50, quantity: 15, available: 15, location: 'B区-01架-01层'},
                {id: 4, isbn: '9787111213826', name: '算法导论', author: 'Thomas H.Cormen', categoryName: '计算机科学', publisher: '机械工业出版社', price: 128.00, quantity: 8, available: 8, location: 'A区-02架-01层'},
                {id: 5, isbn: '9787508647357', name: '经济学原理', author: '曼昆', categoryName: '经济管理', publisher: '北京大学出版社', price: 79.00, quantity: 12, available: 12, location: 'C区-01架-01层'}
            ];
            
            renderBookTable(mockBooks);
        }
        
        // 渲染表格
        function renderBookTable(books) {
            const tbody = document.getElementById('bookTableBody');
            
            if (books.length === 0) {
                tbody.innerHTML = '<tr><td colspan="10" style="text-align: center; padding: 30px; color: #909399;">暂无数据</td></tr>';
                return;
            }
            
            tbody.innerHTML = books.map(book => {
                const isbn = book.isbn || '-';
                const author = book.author || '-';
                const categoryName = book.categoryName || '-';
                const publisher = book.publisher || '-';
                const price = book.price || '-';
                const quantity = book.quantity !== undefined && book.quantity !== null ? book.quantity : 0;
                const available = book.available !== undefined && book.available !== null ? book.available : 0;
                const location = book.location || '-';
                const statusClass = book.available > 0 ? 'status-available' : 'status-borrowed';
                
                return '<tr>' +
                    '<td>' + book.id + '</td>' +
                    '<td>' + isbn + '</td>' +
                    '<td>' + book.name + '</td>' +
                    '<td>' + author + '</td>' +
                    '<td>' + categoryName + '</td>' +
                    '<td>' + publisher + '</td>' +
                    '<td>¥' + price + '</td>' +
                    '<td><span class="status-tag ' + statusClass + '">' + quantity + ' / ' + available + '</span></td>' +
                    '<td>' + location + '</td>' +
                    '<td><div class="action-btns">' +
                        '<button class="btn btn-primary" onclick="editBook(' + book.id + ')">编辑</button>' +
                        '<button class="btn btn-danger" onclick="deleteBook(' + book.id + ')">删除</button>' +
                    '</div></td>' +
                '</tr>';
            }).join('');
            
            document.getElementById('pageInfo').textContent = '共 ' + books.length + ' 条记录';
        }
        
        // 搜索
        function searchBooks() {
            loadBooks();
        }
        
        // 刷新
        function refreshTable() {
            document.getElementById('searchKeyword').value = '';
            document.getElementById('categoryId').value = '';
            loadBooks();
        }
        
        // 打开添加弹窗
        function openAddModal() {
            document.getElementById('modalTitle').textContent = '添加图书';
            document.getElementById('bookForm').reset();
            document.getElementById('bookId').value = '';
            document.getElementById('bookModal').classList.add('show');
        }
        
        // 编辑图书
        function editBook(id) {
            document.getElementById('modalTitle').textContent = '编辑图书';
            document.getElementById('bookId').value = id;
            // 模拟填充数据
            document.getElementById('isbn').value = '9787115428029';
            document.getElementById('name').value = 'Java编程思想';
            document.getElementById('author').value = 'Bruce Eckel';
            document.getElementById('bookCategoryId').value = '2';
            document.getElementById('publisher').value = '机械工业出版社';
            document.getElementById('price').value = '108.00';
            document.getElementById('quantity').value = '10';
            document.getElementById('location').value = 'A区-01架-02层';
            document.getElementById('description').value = 'Java学习经典著作';
            document.getElementById('bookModal').classList.add('show');
        }
        
        // 关闭弹窗
        function closeModal() {
            document.getElementById('bookModal').classList.remove('show');
        }
        
        // 保存图书
        function saveBook() {
            const id = document.getElementById('bookId').value;
            alert(id ? '图书信息已更新！' : '图书添加成功！');
            closeModal();
            loadBooks();
        }
        
        // 删除图书
        function deleteBook(id) {
            if (confirm('确定要删除这本图书吗？')) {
                alert('删除成功！');
                loadBooks();
            }
        }
    </script>
</body>
</html>
