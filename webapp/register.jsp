<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>注册 - 图书馆管理系统</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Microsoft YaHei', sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .register-container {
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            width: 450px;
            padding: 40px;
        }
        .register-header {
            text-align: center;
            margin-bottom: 30px;
        }
        .register-header h1 {
            color: #333;
            font-size: 24px;
            margin-bottom: 10px;
        }
        .register-header p {
            color: #666;
            font-size: 14px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            color: #333;
            font-weight: 500;
            font-size: 14px;
        }
        .form-group input {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        .form-group input:focus {
            outline: none;
            border-color: #667eea;
        }
        .form-row {
            display: flex;
            gap: 15px;
        }
        .form-row .form-group {
            flex: 1;
        }
        .register-btn {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
            margin-top: 10px;
        }
        .register-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
        }
        .error-message {
            background: #fef0f0;
            color: #f56c6c;
            padding: 10px 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            font-size: 14px;
            text-align: center;
        }
        .success-message {
            background: #f0f9ff;
            color: #07c160;
            padding: 10px 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            font-size: 14px;
            text-align: center;
        }
        .links {
            text-align: center;
            margin-top: 20px;
        }
        .links a {
            color: #667eea;
            text-decoration: none;
            font-size: 14px;
        }
        .links a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="register-container">
        <div class="register-header">
            <h1>📚 用户注册</h1>
            <p>创建您的图书馆账户</p>
        </div>
        
        <% if (request.getAttribute("error") != null) { %>
            <div class="error-message">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>
        
        <% if (request.getAttribute("success") != null) { %>
            <div class="success-message">
                <%= request.getAttribute("success") %>
            </div>
        <% } %>
        
        <form action="register" method="post">
            <div class="form-group">
                <label for="username">用户名/学号</label>
                <input type="text" id="username" name="username" placeholder="请输入用户名或学号" required>
            </div>
            
            <div class="form-group">
                <label for="name">姓名</label>
                <input type="text" id="name" name="name" placeholder="请输入真实姓名" required>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label for="phone">手机号</label>
                    <input type="tel" id="phone" name="phone" placeholder="请输入手机号" required>
                </div>
                <div class="form-group">
                    <label for="email">邮箱</label>
                    <input type="email" id="email" name="email" placeholder="请输入邮箱">
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label for="password">密码</label>
                    <input type="password" id="password" name="password" placeholder="请输入密码" required>
                </div>
                <div class="form-group">
                    <label for="confirmPassword">确认密码</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" placeholder="请再次输入密码" required>
                </div>
            </div>
            
            <button type="submit" class="register-btn">立即注册</button>
        </form>
        
        <div class="links">
            已有账户？<a href="login.jsp">立即登录</a>
        </div>
    </div>
</body>
</html>
