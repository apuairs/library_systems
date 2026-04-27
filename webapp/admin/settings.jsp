<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>系统设置 - 图书馆管理系统</title>
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
        
        /* 设置卡片 */
        .settings-container { max-width: 900px; }
        .setting-card { background: white; border-radius: 8px; margin-bottom: 20px; overflow: hidden; box-shadow: 0 2px 12px rgba(0,0,0,0.05); }
        .setting-card-header { padding: 15px 20px; background: #f5f7fa; border-bottom: 1px solid #ebeef5; display: flex; align-items: center; gap: 10px; }
        .setting-card-header h3 { font-size: 16px; color: #303133; }
        .setting-card-body { padding: 25px; }
        
        /* 表单样式 */
        .form-group { margin-bottom: 20px; display: flex; align-items: center; }
        .form-group label { width: 150px; color: #606266; font-size: 14px; flex-shrink: 0; }
        .form-group .form-content { flex: 1; display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
        .form-input { padding: 8px 12px; border: 1px solid #dcdfe6; border-radius: 4px; width: 150px; font-size: 14px; }
        .form-input:focus { outline: none; border-color: #409eff; }
        .form-text { color: #909399; font-size: 13px; }
        .form-hint { color: #c0c4cc; font-size: 12px; margin-top: 5px; }
        
        /* 开关按钮 */
        .switch { position: relative; width: 44px; height: 22px; background: #dcdfe6; border-radius: 11px; cursor: pointer; transition: background 0.3s; }
        .switch.active { background: #409eff; }
        .switch::after { content: ''; position: absolute; width: 18px; height: 18px; background: white; border-radius: 50%; top: 2px; left: 2px; transition: transform 0.3s; }
        .switch.active::after { transform: translateX(22px); }
        
        /* 操作按钮 */
        .btn { padding: 8px 20px; border: none; border-radius: 4px; cursor: pointer; font-size: 14px; transition: all 0.2s; }
        .btn-primary { background: #409eff; color: white; }
        .btn-primary:hover { background: #66b1ff; }
        .btn-success { background: #67c23a; color: white; }
        .btn-success:hover { background: #85ce61; }
        .btn-warning { background: #e6a23c; color: white; }
        .btn-warning:hover { background: #ebb563; }
        .btn-group { display: flex; gap: 10px; padding-top: 10px; border-top: 1px solid #ebeef5; }
        
        /* 通知样式 */
        .toast { position: fixed; top: 20px; right: 20px; padding: 15px 20px; background: white; border-radius: 4px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); display: none; align-items: center; gap: 10px; z-index: 10000; animation: slideIn 0.3s ease; }
        .toast.show { display: flex; }
        .toast.success { border-left: 4px solid #67c23a; }
        .toast.success .icon { color: #67c23a; }
        @keyframes slideIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
        
        /* 配置项列表 */
        .config-list { display: flex; flex-direction: column; gap: 15px; }
        .config-item { display: flex; align-items: center; padding: 15px; background: #f5f7fa; border-radius: 4px; }
        .config-item .config-label { width: 180px; color: #303133; font-size: 14px; }
        .config-item .config-value { flex: 1; color: #606266; }
        .config-item .config-action { }
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
                <li><a href="statistics.jsp"><i>📈</i> 统计分析</a></li>
                <li><a href="settings.jsp" class="active"><i>⚙️</i> 系统设置</a></li>
            </ul>
        </div>
        
        <!-- 主内容区 -->
        <div class="main-content">
            <div class="top-header">
                <div class="header-left">系统设置</div>
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
                    <h2>系统设置</h2>
                    <p>配置图书馆管理系统的各项参数</p>
                </div>
                
                <div class="settings-container">
                    <!-- 借阅规则设置 -->
                    <div class="setting-card">
                        <div class="setting-card-header">
                            <span>📖</span>
                            <h3>借阅规则设置</h3>
                        </div>
                        <div class="setting-card-body">
                            <div class="form-group">
                                <label>最大借阅数量</label>
                                <div class="form-content">
                                    <input type="number" class="form-input" id="maxBooks" value="10" min="1">
                                    <span class="form-text">本</span>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>借阅期限</label>
                                <div class="form-content">
                                    <input type="number" class="form-input" id="borrowDays" value="30" min="1">
                                    <span class="form-text">天</span>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>最大续借次数</label>
                                <div class="form-content">
                                    <input type="number" class="form-input" id="renewTimes" value="2" min="0">
                                    <span class="form-text">次</span>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>预约保留时间</label>
                                <div class="form-content">
                                    <input type="number" class="form-input" id="reserveDays" value="3" min="1">
                                    <span class="form-text">天</span>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>逾期每日罚款</label>
                                <div class="form-content">
                                    <input type="number" class="form-input" id="overdueFine" value="0.1" min="0" step="0.1">
                                    <span class="form-text">元 / 天</span>
                                </div>
                            </div>
                            <div class="btn-group">
                                <button class="btn btn-primary" onclick="saveBorrowSettings()">保存设置</button>
                                <button class="btn btn-warning" onclick="resetBorrowSettings()">恢复默认</button>
                            </div>
                        </div>
                    </div>
                    
                    <!-- 座位预约设置 -->
                    <div class="setting-card">
                        <div class="setting-card-header">
                            <span>💺</span>
                            <h3>座位预约设置</h3>
                        </div>
                        <div class="setting-card-body">
                            <div class="form-group">
                                <label>最长预约天数</label>
                                <div class="form-content">
                                    <input type="number" class="form-input" id="maxReserveDays" value="7" min="1">
                                    <span class="form-text">天（最多可预约未来7天）</span>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>每日最大预约时长</label>
                                <div class="form-content">
                                    <input type="number" class="form-input" id="maxReserveHours" value="8" min="1">
                                    <span class="form-text">小时</span>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>签到超时时间</label>
                                <div class="form-content">
                                    <input type="number" class="form-input" id="checkInTimeout" value="15" min="5">
                                    <span class="form-text">分钟（预约后超时未签到自动取消）</span>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>最大违约次数</label>
                                <div class="form-content">
                                    <input type="number" class="form-input" id="maxViolation" value="3" min="1">
                                    <span class="form-text">次（冻结账号）</span>
                                </div>
                            </div>
                            <div class="btn-group">
                                <button class="btn btn-primary" onclick="saveSeatSettings()">保存设置</button>
                                <button class="btn btn-warning" onclick="resetSeatSettings()">恢复默认</button>
                            </div>
                        </div>
                    </div>
                    
                    <!-- 系统功能开关 -->
                    <div class="setting-card">
                        <div class="setting-card-header">
                            <span>🔌</span>
                            <h3>功能开关</h3>
                        </div>
                        <div class="setting-card-body">
                            <div class="form-group">
                                <label>用户注册</label>
                                <div class="form-content">
                                    <div class="switch active" id="switchRegister" onclick="toggleSwitch(this)"></div>
                                    <span class="form-text">允许新用户注册</span>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>座位预约</label>
                                <div class="form-content">
                                    <div class="switch active" id="switchSeat" onclick="toggleSwitch(this)"></div>
                                    <span class="form-text">启用座位预约功能</span>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>图书预约</label>
                                <div class="form-content">
                                    <div class="switch active" id="switchBookReserve" onclick="toggleSwitch(this)"></div>
                                    <span class="form-text">允许用户预约已借出的图书</span>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>逾期提醒</label>
                                <div class="form-content">
                                    <div class="switch active" id="switchReminder" onclick="toggleSwitch(this)"></div>
                                    <span class="form-text">到期前3天发送提醒通知</span>
                                </div>
                            </div>
                            <div class="btn-group">
                                <button class="btn btn-primary" onclick="saveSwitchSettings()">保存设置</button>
                            </div>
                        </div>
                    </div>
                    
                    <!-- 数据管理 -->
                    <div class="setting-card">
                        <div class="setting-card-header">
                            <span>💾</span>
                            <h3>数据管理</h3>
                        </div>
                        <div class="setting-card-body">
                            <div class="form-group">
                                <label>备份数据库</label>
                                <div class="form-content">
                                    <button class="btn btn-success" onclick="backupDatabase()">立即备份</button>
                                    <span class="form-text">自动备份：每天凌晨 2:00</span>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>恢复数据库</label>
                                <div class="form-content">
                                    <button class="btn btn-warning" onclick="restoreDatabase()">选择备份文件</button>
                                    <input type="file" id="backupFile" style="display: none;" accept=".sql">
                                </div>
                            </div>
                            <div class="form-group">
                                <label>清理过期数据</label>
                                <div class="form-content">
                                    <button class="btn btn-danger" onclick="cleanOldData()">清理一年前的记录</button>
                                    <span class="form-hint">仅删除一年前的借阅历史和日志，不影响当前数据</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- 当前配置列表 -->
                    <div class="setting-card">
                        <div class="setting-card-header">
                            <span>📋</span>
                            <h3>当前配置</h3>
                        </div>
                        <div class="setting-card-body">
                            <div class="config-list">
                                <div class="config-item">
                                    <div class="config-label">最大借阅数量</div>
                                    <div class="config-value">10 本</div>
                                </div>
                                <div class="config-item">
                                    <div class="config-label">借阅期限</div>
                                    <div class="config-value">30 天</div>
                                </div>
                                <div class="config-item">
                                    <div class="config-label">最大续借次数</div>
                                    <div class="config-value">2 次</div>
                                </div>
                                <div class="config-item">
                                    <div class="config-label">最长预约天数</div>
                                    <div class="config-value">7 天</div>
                                </div>
                                <div class="config-item">
                                    <div class="config-label">用户注册</div>
                                    <div class="config-value" style="color: #67c23a;">已启用</div>
                                </div>
                                <div class="config-item">
                                    <div class="config-label">座位预约</div>
                                    <div class="config-value" style="color: #67c23a;">已启用</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- 通知提示 -->
    <div class="toast success" id="toast">
        <span class="icon">✓</span>
        <span id="toastMessage">设置已保存</span>
    </div>
    
    <script>
        // 开关切换
        function toggleSwitch(el) {
            el.classList.toggle('active');
        }
        
        // 显示通知
        function showToast(message) {
            const toast = document.getElementById('toast');
            document.getElementById('toastMessage').textContent = message;
            toast.classList.add('show');
            setTimeout(() => toast.classList.remove('show'), 3000);
        }
        
        // 保存借阅设置
        function saveBorrowSettings() {
            const maxBooks = document.getElementById('maxBooks').value;
            const borrowDays = document.getElementById('borrowDays').value;
            const renewTimes = document.getElementById('renewTimes').value;
            const reserveDays = document.getElementById('reserveDays').value;
            const overdueFine = document.getElementById('overdueFine').value;
            
            console.log('保存借阅设置:', { maxBooks, borrowDays, renewTimes, reserveDays, overdueFine });
            showToast('借阅规则设置已保存！');
        }
        
        // 重置借阅设置
        function resetBorrowSettings() {
            if (confirm('确定要恢复默认设置吗？')) {
                document.getElementById('maxBooks').value = 10;
                document.getElementById('borrowDays').value = 30;
                document.getElementById('renewTimes').value = 2;
                document.getElementById('reserveDays').value = 3;
                document.getElementById('overdueFine').value = 0.1;
                showToast('已恢复默认设置！');
            }
        }
        
        // 保存座位设置
        function saveSeatSettings() {
            const maxReserveDays = document.getElementById('maxReserveDays').value;
            const maxReserveHours = document.getElementById('maxReserveHours').value;
            const checkInTimeout = document.getElementById('checkInTimeout').value;
            const maxViolation = document.getElementById('maxViolation').value;
            
            console.log('保存座位设置:', { maxReserveDays, maxReserveHours, checkInTimeout, maxViolation });
            showToast('座位预约设置已保存！');
        }
        
        // 重置座位设置
        function resetSeatSettings() {
            if (confirm('确定要恢复默认设置吗？')) {
                document.getElementById('maxReserveDays').value = 7;
                document.getElementById('maxReserveHours').value = 8;
                document.getElementById('checkInTimeout').value = 15;
                document.getElementById('maxViolation').value = 3;
                showToast('已恢复默认设置！');
            }
        }
        
        // 保存开关设置
        function saveSwitchSettings() {
            const register = document.getElementById('switchRegister').classList.contains('active');
            const seat = document.getElementById('switchSeat').classList.contains('active');
            const bookReserve = document.getElementById('switchBookReserve').classList.contains('active');
            const reminder = document.getElementById('switchReminder').classList.contains('active');
            
            console.log('保存开关设置:', { register, seat, bookReserve, reminder });
            showToast('功能开关设置已保存！');
        }
        
        // 备份数据库
        function backupDatabase() {
            showToast('数据库备份任务已启动，请稍候...');
            setTimeout(() => showToast('数据库备份完成！'), 1500);
        }
        
        // 恢复数据库
        function restoreDatabase() {
            document.getElementById('backupFile').click();
        }
        
        // 清理过期数据
        function cleanOldData() {
            if (confirm('确定要清理一年前的历史数据吗？此操作不可撤销！')) {
                showToast('正在清理过期数据...');
                setTimeout(() => showToast('数据清理完成！'), 1500);
            }
        }
        
        // 文件选择
        document.getElementById('backupFile').addEventListener('change', function(e) {
            if (e.target.files.length > 0) {
                if (confirm('确定要从备份文件 ' + e.target.files[0].name + ' 恢复数据吗？当前数据将被覆盖！')) {
                    showToast('正在恢复数据，请稍候...');
                    setTimeout(() => showToast('数据恢复成功！'), 2000);
                }
            }
        });
    </script>
</body>
</html>
