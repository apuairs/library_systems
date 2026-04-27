package com.library.dao;

import com.library.model.Seat;
import com.library.model.SeatReservation;
import com.library.model.Violation;
import com.library.util.DBUtil;


import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SeatDAO extends BaseDAO<Seat> {
    
    @Override
    protected Seat mapRow(ResultSet rs) throws SQLException {
        Seat seat = new Seat();
        seat.setId(rs.getInt("id"));
        try {
            if (rs.findColumn("floor") > 0) {
                seat.setFloor(rs.getInt("floor"));
            }
        } catch (SQLException e) {
            // 字段不存在，忽略
        }
        seat.setArea(rs.getString("area"));
        seat.setSeatNumber(rs.getString("seat_number"));
        try {
            if (rs.findColumn("row_num") > 0) {
                // 兼容旧字段
            }
        } catch (SQLException e) {
            // 字段不存在，忽略
        }
        try {
            if (rs.findColumn("col_num") > 0) {
                // 兼容旧字段
            }
        } catch (SQLException e) {
            // 字段不存在，忽略
        }
        seat.setStatus(rs.getInt("status"));
        try {
            if (rs.findColumn("description") > 0) {
                seat.setDescription(rs.getString("description"));
            }
        } catch (SQLException e) {
            // 字段不存在，忽略
        }
        // 检查是否有is_reserved字段
        try {
            if (rs.findColumn("is_reserved") > 0) {
                seat.setIsReserved(rs.getInt("is_reserved") == 1);
            }
        } catch (SQLException e) {
        }
        return seat;
    }
    
    public List<Seat> findAllSeats() {
        String sql = "SELECT * FROM seat ORDER BY area, seat_number";
        return query(sql);
    }
    
    public Seat findSeatById(Integer id) {
        String sql = "SELECT * FROM seat WHERE id = ?";
        return queryOne(sql, id);
    }
    
    public List<Seat> findSeatStatus(String date, String startTime, String endTime) {
        String sql = "SELECT s.*, " +
                     "MAX(CASE WHEN sr.id IS NOT NULL THEN 1 ELSE 0 END) as is_reserved " +
                     "FROM seat s " +
                     "LEFT JOIN seat_reservation sr ON s.id = sr.seat_id " +
                     "AND sr.reserve_date = ? " +
                     "AND sr.status IN (0, 1) " +
                     "AND ((sr.start_time <= '08:00:00' AND sr.end_time > '08:00:00') OR " +
                     "(sr.start_time < '22:00:00' AND sr.end_time >= '22:00:00') OR " +
                     "(sr.start_time >= '08:00:00' AND sr.end_time <= '22:00:00')) " +
                     "WHERE s.status = 1 " +
                     "GROUP BY s.id " +
                     "ORDER BY s.area, s.seat_number";
        List<Seat> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, date);
            rs = ps.executeQuery();
            while (rs.next()) {
                Seat seat = mapRow(rs);
                list.add(seat);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }
    
    public boolean checkSeatReserved(Integer seatId, String date, String startTime, String endTime) {
        String sql = "SELECT COUNT(*) FROM seat_reservation " +
                     "WHERE seat_id = ? AND reserve_date = ? " +
                     "AND status IN (0, 1) " +
                     "AND ((start_time <= ? AND end_time > ?) " +
                     "OR (start_time < ? AND end_time >= ?))";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, seatId);
            ps.setString(2, date);
            ps.setString(3, startTime);
            ps.setString(4, startTime);
            ps.setString(5, endTime);
            ps.setString(6, endTime);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return false;
    }
    
    public int countActiveReservations(Integer userId) {
        String sql = "SELECT COUNT(*) FROM seat_reservation WHERE user_id = ? AND status IN (0, 1)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return 0;
    }
    
    public int countTodayReservations(Integer userId, String date) {
        String sql = "SELECT COUNT(*) FROM seat_reservation WHERE user_id = ? AND reserve_date = ? AND status IN (0, 1)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, date);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return 0;
    }
    
    public int insertReservation(SeatReservation reservation) {
        String sql = "INSERT INTO seat_reservation (user_id, seat_id, reserve_date, start_time, end_time, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        return update(sql, reservation.getUserId(), reservation.getSeatId(), reservation.getReserveDate(),
                reservation.getStartTime(), reservation.getEndTime(), reservation.getStatus());
    }
    
    public SeatReservation findReservationById(Integer id) {
        String sql = "SELECT sr.*, u.name as user_name, s.seat_number, s.area " +
                     "FROM seat_reservation sr " +
                     "LEFT JOIN user u ON sr.user_id = u.id " +
                     "LEFT JOIN seat s ON sr.seat_id = s.id " +
                     "WHERE sr.id = ?";
        List<SeatReservation> list = queryReservation(sql, id);
        return list.isEmpty() ? null : list.get(0);
    }
    
    public List<SeatReservation> findReservationsByUserId(Integer userId) {
        String sql = "SELECT sr.*, u.name as user_name, s.seat_number, s.area " +
                     "FROM seat_reservation sr " +
                     "LEFT JOIN user u ON sr.user_id = u.id " +
                     "LEFT JOIN seat s ON sr.seat_id = s.id " +
                     "WHERE sr.user_id = ? " +
                     "ORDER BY sr.reserve_date DESC, sr.start_time DESC";
        return queryReservation(sql, userId);
    }
    
    public List<SeatReservation> findAllReservations() {
        String sql = "SELECT sr.*, u.name as user_name, s.seat_number, s.area " +
                     "FROM seat_reservation sr " +
                     "LEFT JOIN user u ON sr.user_id = u.id " +
                     "LEFT JOIN seat s ON sr.seat_id = s.id " +
                     "ORDER BY sr.reserve_date DESC, sr.start_time DESC";
        return queryReservation(sql);
    }
    
    public int updateReservation(SeatReservation reservation) {
        String sql = "UPDATE seat_reservation SET check_in_time=?, check_out_time=?, status=? WHERE id=?";
        return update(sql, reservation.getCheckinTime(), reservation.getCheckoutTime(),
                reservation.getStatus(), reservation.getId());
    }
    
    public int updateSeat(Seat seat) {
        String sql = "UPDATE seat SET floor=?, area=?, seat_number=?, status=?, description=? WHERE id=?";
        return update(sql, seat.getFloor(), seat.getArea(), seat.getSeatNumber(),
                seat.getStatus(), seat.getDescription(), seat.getId());
    }
    
    public int insertSeat(Seat seat) {
        String sql = "INSERT INTO seat (floor, area, seat_number, status, description) VALUES (?, ?, ?, ?, ?)";
        return update(sql, seat.getFloor(), seat.getArea(), seat.getSeatNumber(),
                seat.getStatus(), seat.getDescription());
    }
    
    public int insertViolation(Integer userId, Integer type, Integer relatedId, String reason) {
        String sql = "INSERT INTO violation (user_id, type, related_id, reason, handle_status) VALUES (?, ?, ?, ?, 0)";
        return update(sql, userId, type, relatedId, reason);
    }
    
    public int updateViolationStatus(Integer violationId, Integer status, Integer handleBy) {
        String sql = "UPDATE violation SET handle_status=?, handle_by=? WHERE id=?";
        return update(sql, status, handleBy, violationId);
    }
    
    private List<SeatReservation> queryReservation(String sql, Object... params) {
        List<SeatReservation> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                SeatReservation sr = new SeatReservation();
                sr.setId(rs.getInt("id"));
                sr.setUserId(rs.getInt("user_id"));
                sr.setUserName(rs.getString("user_name"));
                sr.setSeatId(rs.getInt("seat_id"));
                sr.setSeatNumber(rs.getString("seat_number"));
                sr.setArea(rs.getString("area"));
                sr.setReserveDate(rs.getString("reserve_date"));
                sr.setStartTime(rs.getString("start_time"));
                sr.setEndTime(rs.getString("end_time"));
                sr.setReserveTime(rs.getTimestamp("create_time"));
                sr.setCheckinTime(rs.getTimestamp("check_in_time"));
                sr.setCheckoutTime(rs.getTimestamp("check_out_time"));
                sr.setStatus(rs.getInt("status"));
                try {
                    sr.setViolationRecord(rs.getBoolean("violation_record"));
                } catch (SQLException e) {
                    sr.setViolationRecord(false);
                }
                list.add(sr);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }
    
    public int updateSeatStatus(Integer seatId, int status) {
        String sql = "UPDATE seat SET status = ? WHERE id = ?";
        return update(sql, status, seatId);
    }
}