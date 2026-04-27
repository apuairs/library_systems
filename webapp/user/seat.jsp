<!-- user/seat.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.library.model.User"%>
<%@ page import="com.library.service.SeatService"%>
<%@ page import="com.library.model.Seat"%>
<%@ page import="java.util.List"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    SeatService seatService = new SeatService();
    List<Seat> seats = seatService.getAllSeats();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String today = sdf.format(new Date());
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>座位预约 - 图书馆管理系统</title>
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
        .page-title { margin-bottom: 20px; color: #333; }
        
        .date-selector { background: white; padding: 20px; border-radius: 10px; margin-bottom: 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .date-selector label { font-size: 16px; margin-right: 10px; }
        .date-selector input { padding: 8px 12px; border: 1px solid #ddd; border-radius: 5px; font-size: 14px; }
        .date-selector button { padding: 8px 20px; background: #3498db; border: none; border-radius: 5px; color: white; cursor: pointer; }
        
        .time-selector { margin-top: 15px; display: flex; gap: 10px; flex-wrap: wrap; }
        .time-slot { padding: 8px 20px; border: 1px solid #ddd; border-radius: 5px; background: white; cursor: pointer; transition: all 0.3s; }
        .time-slot.selected { background: #3498db; color: white; border-color: #3498db; }
        
        .seat-map { background: white; border-radius: 10px; padding: 20px; margin-bottom: 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .area-title { font-size: 18px; font-weight: bold; margin: 20px 0 10px; padding-bottom: 10px; border-bottom: 2px solid #3498db; }
        .area-title:first-child { margin-top: 0; }
        .seat-grid { display: flex; flex-wrap: wrap; gap: 10px; }
        .seat { width: 80px; padding: 15px 5px; text-align: center; border-radius: 8px; cursor: pointer; transition: all 0.3s; }
        .seat-available { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .seat-available:hover { transform: scale(1.05); background: #c3e6cb; }
        .seat-reserved { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; cursor: not-allowed; }
        .seat-selected { background: #3498db; color: white; border-color: #3498db; transform: scale(1.05); }
        .seat-maintenance { background: #e2e3e5; color: #6c757d; border: 1px solid #d6d8db; cursor: not-allowed; }
        
        .legend { display: flex; gap: 20px; margin-top: 20px; padding-top: 20px; border-top: 1px solid #eee; }
        .legend-item { display: flex; align-items: center; gap: 8px; }
        .legend-color { width: 20px; height: 20px; border-radius: 4px; }
        
        .reserve-btn { width: 100%; padding: 12px; background: #27ae60; border: none; border-radius: 5px; color: white; font-size: 16px; cursor: pointer; margin-top: 20px; }
        .reserve-btn:disabled { background: #95a5a6; cursor: not-allowed; }
        
        .footer { background: #2c3e50; color: #95a5a6; text-align: center; padding: 20px 0; margin-top: 50px; }
        
        .alert { padding: 12px 20px; border-radius: 5px; margin-bottom: 20px; }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
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
                <span>欢迎，<%= user.getName() %></span>
                <a href="<%= request.getContextPath() %>/logout" class="logout-btn">退出</a>
            </div>
        </div>
    </div>
    
    <div class="main">
        <div class="container">
            <h2 class="page-title">💺 座位预约</h2>
            
            <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
            <% } %>
            <% if (request.getAttribute("message") != null) { %>
            <div class="alert alert-success"><%= request.getAttribute("message") %></div>
            <% } %>
            
            <div class="date-selector">
                <label>选择日期：</label>
                <input type="date" id="reserveDate" value="<%= today %>" min="<%= today %>">
                <button onclick="loadSeatStatus()">查看座位</button>
                <button onclick="showMyReservations()" style="margin-left: 10px; background: #f39c12; border: none; padding: 8px 20px; border-radius: 5px; color: white; cursor: pointer;">查看我的预约</button>
            </div>
            
            <div class="seat-map" id="seatMap">
                <div style="text-align: center; padding: 50px; color: #999;">请选择日期查看座位状态</div>
            </div>
            
            <form id="reserveForm" action="<%= request.getContextPath() %>/seatReserve" method="post" style="display:none;">
                <input type="hidden" name="seatId" id="selectedSeatId">
                <input type="hidden" name="date" id="selectedDate">
                <input type="hidden" name="startTime" id="selectedStartTime">
                <input type="hidden" name="endTime" id="selectedEndTime">
                <button type="submit" class="reserve-btn" id="reserveBtn">确认预约</button>
            </form>
        </div>
    </div>
    
    <div class="footer">
        <div class="container">
            <p>© 2024 图书馆管理系统</p>
        </div>
    </div>
    
    <!-- 已预约座位弹窗 -->
    <div id="reservationModal" style="display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0,0,0,0.4);">
        <div style="background-color: #fefefe; margin: 15% auto; padding: 20px; border: 1px solid #888; width: 80%; max-width: 600px; border-radius: 10px; position: relative;">
            <span onclick="closeModal()" style="color: #aaa; float: right; font-size: 28px; font-weight: bold; cursor: pointer;">&times;</span>
            <div id="reservationModalContent"></div>
        </div>
    </div>
    
    <script>
        let selectedSeat = null;
        
        document.addEventListener('DOMContentLoaded', function() {
            loadSeatStatus();
        });
        
        function loadSeatStatus() {
            var date = document.getElementById('reserveDate').value;
            
            fetch('<%= request.getContextPath() %>/api/seats?date=' + encodeURIComponent(date), {
                headers: {
                    'Accept': 'application/json'
                }
            })
                .then(function(response) {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(function(data) {
                    renderSeatMap(data, date);
                })
                .catch(function(error) {
                    console.error('Error:', error);
                    document.getElementById('seatMap').innerHTML = '<div style="text-align: center; padding: 50px; color: #999;">加载座位状态失败，请重试</div>';
                });
        }
        
        function renderSeatMap(seats, date) {
            var areas = {};
            seats.forEach(function(seat) {
                if (!areas[seat.area]) areas[seat.area] = [];
                areas[seat.area].push(seat);
            });
            
            var html = '';
            for (var area in areas) {
                if (areas.hasOwnProperty(area)) {
                    html += '<div class="area-title">' + area + '</div>';
                    html += '<div class="seat-grid">';
                    areas[area].forEach(function(seat) {
                        var statusClass = 'seat-available';
                        var statusText = '可预约';
                        if (seat.status === 0) {
                            statusClass = 'seat-maintenance';
                            statusText = '维护中';
                        } else if (seat.isReserved) {
                            statusClass = 'seat-reserved';
                            statusText = '已预约';
                        }
                        
                        var onclickStr = '';
                        if (seat.status === 1 && !seat.isReserved) {
                            onclickStr = 'selectSeat(' + seat.id + ', \'' + seat.seatNumber + '\')';
                        }
                        
                        html += '<div class="seat ' + statusClass + '" data-seat-id="' + seat.id + '" data-seat-number="' + seat.seatNumber + '"';
                        if (onclickStr) {
                            html += ' onclick="' + onclickStr + '"';
                        }
                        html += '>';
                        html += seat.seatNumber;
                        html += '<br><small>' + statusText + '</small>';
                        html += '</div>';
                    });
                    html += '</div>';
                }
            }
            document.getElementById('seatMap').innerHTML = html;
        }
        
        function selectSeat(seatId, seatNumber) {
            if (selectedSeat) {
                var prevSeat = document.querySelector('.seat[data-seat-id="' + selectedSeat + '"]');
                if (prevSeat) prevSeat.classList.remove('seat-selected');
            }
            selectedSeat = seatId;
            var seatElement = document.querySelector('.seat[data-seat-id="' + seatId + '"]');
            seatElement.classList.add('seat-selected');
            
            // 设置默认时间段（8:00-22:00）
            document.getElementById('selectedSeatId').value = seatId;
            document.getElementById('selectedDate').value = document.getElementById('reserveDate').value;
            document.getElementById('selectedStartTime').value = '08:00';
            document.getElementById('selectedEndTime').value = '22:00';
            document.getElementById('reserveForm').style.display = 'block';
        }
        
        // 显示已预约座位弹窗
        function showMyReservations() {
            fetch('<%= request.getContextPath() %>/api/my-reservations', {
                headers: {
                    'Accept': 'application/json'
                }
            })
                .then(function(response) {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(function(data) {
                    var reservations = data.reservations || [];
                    var modal = document.getElementById('reservationModal');
                    var modalContent = document.getElementById('reservationModalContent');
                    
                    var html = '';
                    if (reservations.length > 0) {
                        html += '<h3>当前已预约座位</h3>';
                        html += '<ul>';
                        reservations.forEach(function(res) {
                            html += '<li>';
                            html += '<strong>座位：' + res.seatNumber + ' (' + res.area + '区)</strong><br>';
                            html += '日期：' + res.reserveDate + '<br>';
                            html += '时间：' + res.startTime + ' - ' + res.endTime + '<br>';
                            html += '状态：' + res.statusText + '<br>';
                            html += '<small>预约时间：' + new Date(res.reserveTime).toLocaleString() + '</small>';
                            html += '</li>';
                        });
                        html += '</ul>';
                    } else {
                        html += '<h3>当前无预约座位</h3>';
                    }
                    
                    modalContent.innerHTML = html;
                    modal.style.display = 'block';
                })
                .catch(function(error) {
                    console.error('Error:', error);
                    alert('获取预约信息失败');
                });
        }
        
        // 关闭弹窗
        function closeModal() {
            document.getElementById('reservationModal').style.display = 'none';
        }
        
        // 点击弹窗外部关闭
        window.onclick = function(event) {
            var modal = document.getElementById('reservationModal');
            if (event.target == modal) {
                modal.style.display = 'none';
            }
        }
    </script>
</body>
</html>