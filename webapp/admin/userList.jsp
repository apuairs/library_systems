<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户管理 - 图书馆管理系统</title>
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
        .status-normal { background: #f0f9ff; color: #67c23a; }
        .status-frozen { background: #fef0f0; color: #f56c6c; }
        .status-pending { background: #fdf6ec; color: #e6a23c; }
        .role-admin { background: #eef2ff; color: #409eff; }
        .role-user { background: #f0f2f5; color: #909399; }
        
        /* 分页 */
        .pagination { display: flex; justify-content: flex-end; align-items: center; gap: 10px; padding: 15px 20px; background: white; border-top: 1px solid #ebeef5; }
        .pagination span { color: #909399; font-size: 14px; }
        .page-btn { padding: 5px 10px; border: 1px solid #dcdfe6; background: white; border-radius: 4px; cursor: pointer; font-size: 14px; color: #606266; }
        .page-btn:hover { border-color: #409eff; color: #409eff; }
        .page-btn.active { background: #409eff; color: white; border-color: #409eff; }
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
                <li><a href="userList.jsp" class="active"><i>👥</i> 用户管理</a></li>
                <li><a href="borrowList.jsp"><i>📋</i> 借阅管理</a></li>
                <li><a href="seatManage.jsp"><i>💺</i> 座位管理</a></li>
                <li><a href="statistics.jsp"><i>📈</i> 统计分析</a></li>
                <li><a href="settings.jsp"><i>⚙️</i> 系统设置</a></li>
            </ul>
        </div>
        
        <!-- 主内容区 -->
        <div class="main-content">
            <div class="top-header">
                <div class="header-left">用户管理</div>
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
                    <h2>用户管理</h2>
                    <p>管理系统用户、查看借阅记录、处理违规行为</p>
                </div>
                
                <!-- 工具栏 -->
                <div class="toolbar">
                    <input type="text" class="search-input" placeholder="搜索用户名/姓名/手机号..." id="searchKeyword">
                    <select class="search-input" id="userStatus">
                        <option value="">全部状态</option>
                        <option value="1">正常</option>
                        <option value="0">冻结</option>
                        <option value="2">待审核</option>
                    </select>
                    <select class="search-input" id="userRole">
                        <option value="">全部角色</option>
                        <option value="1">管理员</option>
                        <option value="0">普通用户</option>
                    </select>
                    <button class="btn btn-primary" onclick="searchUsers()"><i>🔍</i> 搜索</button>
                    <button class="btn btn-warning" onclick="refreshTable()"><i>🔄</i> 刷新</button>
                </div>
                
                <!-- 数据表格 -->
                <div class="data-table">
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>用户名/学号</th>
                                <th>姓名</th>
                                <th>手机号</th>
                                <th>邮箱</th>
                                <th>角色</th>
                                <th>状态</th>
                                <th>违规次数</th>
                                <th>注册时间</th>
                                <th>操作</th>
                            </tr>
                        </thead>
                        <tbody id="userTableBody">
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
    
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            loadUsers();
        });
        
        function loadUsers(page = 1) {
            const mockUsers = [
                {id: 1, username: 'admin', name: '系统管理员', phone: '13800138000', email: 'admin@library.com', role: 1, status: 1, violationCount: 0, createTime: '2024-01-01 10:00:00'},
                {id: 2, username: 'test', name: '测试用户', phone: '13800138001', email: 'test@library.com', role: 0, status: 1, violationCount: 0, createTime: '2024-01-15 14:30:00'},
                {id: 3, username: 'zhangsan', name: '张三', phone: '13800138002', email: 'zhangsan@email.com', role: 0, status: 1, violationCount: 2, createTime: '2024-02-01 09:15:00'},
                {id: 4, username: 'lisi', name: '李四', phone: '13800138003', email: 'lisi@email.com', role: 0, status: 0, violationCount: 5, createTime: '2024-02-10 16:45:00'},
                {id: 5, username: 'wangwu', name: '王五', phone: '13800138004', email: 'wangwu@email.com', role: 0, status: 2, violationCount: 0, createTime: '2024-03-01 11:20:00'}
            ];
            
            renderUserTable(mockUsers);
        }
        
        function renderUserTable(users) {
            const tbody = document.getElementById('userTableBody');
            
            if (users.length === 0) {
                tbody.innerHTML = '<tr><td colspan="10" style="text-align: center; padding: 30px; color: #909399;">暂无数据</td></tr>';
                return;
            }
            
            tbody.innerHTML = users.map(user => {
                let statusClass = 'status-normal';
                let statusText = '正常';
                if (user.status === 0) { statusClass = 'status-frozen'; statusText = '冻结'; }
                if (user.status === 2) { statusClass = 'status-pending'; statusText = '待审核'; }
                
                const roleClass = user.role === 1 ? 'role-admin' : 'role-user';
                const roleText = user.role === 1 ? '管理员' : '普通用户';
                
                let actionButtons = '<button class="btn btn-primary" onclick="viewUser(' + user.id + ')">详情</button>';
                if (user.status === 1) {
                    actionButtons += '<button class="btn btn-danger" onclick="freezeUser(' + user.id + ', \'' + user.name + '\')">冻结</button>';
                } else if (user.status === 0) {
                    actionButtons += '<button class="btn btn-success" onclick="unfreezeUser(' + user.id + ', \'' + user.name + '\')">解冻</button>';
                } else {
                    actionButtons += '<button class="btn btn-success" onclick="approveUser(' + user.id + ', \'' + user.name + '\')">审核</button>';
                }
                
                return '<tr>' +
                    '<td>' + user.id + '</td>' +
                    '<td>' + user.username + '</td>' +
                    '<td>' + user.name + '</td>' +
                    '<td>' + (user.phone || '-') + '</td>' +
                    '<td>' + (user.email || '-') + '</td>' +
                    '<td><span class="status-tag ' + roleClass + '">' + roleText + '</span></td>' +
                    '<td><span class="status-tag ' + statusClass + '">' + statusText + '</span></td>' +
                    '<td>' + user.violationCount + '</td>' +
                    '<td>' + user.createTime + '</td>' +
                    '<td><div class="action-btns">' + actionButtons + '</div></td>' +
                '</tr>';
            }).join('');
            
            document.getElementById('pageInfo').textContent = '共 ' + users.length + ' 条记录';
        }
        
        function searchUsers() {
            loadUsers();
        }
        
        function refreshTable() {
            document.getElementById('searchKeyword').value = '';
            document.getElementById('userStatus').value = '';
            document.getElementById('userRole').value = '';
            loadUsers();
        }
        
        function viewUser(id) {
            alert('查看用户详情功能 - 用户ID: ' + id);
        }
        
        function freezeUser(id, name) {
            if (confirm(`确定要冻结用户 "${name}" 吗？`)) {
                alert('用户已冻结！');
                loadUsers();
            }
        }
        
        function unfreezeUser(id, name) {
            if (confirm(`确定要解冻用户 "${name}" 吗？`)) {
                alert('用户已解冻！');
                loadUsers();
            }
        }
        
        function approveUser(id, name) {
            if (confirm(`确定要审核通过用户 "${name}" 吗？`)) {
                alert('用户审核通过！');
                loadUsers();
            }
        }
    </script>
</body>
</html>
