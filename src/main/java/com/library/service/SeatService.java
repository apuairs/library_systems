// service/SeatService.java
package com.library.service;

import com.library.dao.SeatDAO;
import com.library.model.Seat;
import com.library.model.SeatReservation;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.List;

public class SeatService {
    private SeatDAO seatDAO = new SeatDAO();
    
    public List<Seat> getAllSeats() {
        return seatDAO.findAllSeats();
    }
    
    public List<Seat> getSeatStatus(String date) {
        return seatDAO.findSeatStatus(date, null, null);
    }
    
    public List<Seat> getSeatStatus(String date, String startTime, String endTime) {
        return seatDAO.findSeatStatus(date, startTime, endTime);
    }
    
    public boolean reserveSeat(Integer userId, Integer seatId, String date, String startTime, String endTime) {
        Seat seat = seatDAO.findSeatById(seatId);
        if (seat == null || seat.getStatus() != 1) {
            throw new RuntimeException("座位不可用");
        }
        
        int activeReservations = seatDAO.countActiveReservations(userId);
        if (activeReservations > 0) {
            throw new RuntimeException("您已有未完成的预约，请先取消或完成当前预约后再预约新座位");
        }
        
        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm:ss");
        String reserveDate = now.format(dateFormatter);
        String reserveStartTime = now.format(timeFormatter);
        String reserveEndTime = now.plusMinutes(30).format(timeFormatter);
        
        boolean isReserved = seatDAO.checkSeatReserved(seatId, reserveDate, reserveStartTime, reserveEndTime);
        if (isReserved) {
            throw new RuntimeException("该座位在此时间段已被预约");
        }
        
        int todayReservations = seatDAO.countTodayReservations(userId, reserveDate);
        if (todayReservations >= 3) {
            throw new RuntimeException("当天最多预约3个时段");
        }
        
        SeatReservation reservation = new SeatReservation();
        reservation.setUserId(userId);
        reservation.setSeatId(seatId);
        reservation.setReserveDate(reserveDate);
        reservation.setStartTime(reserveStartTime);
        reservation.setEndTime(reserveEndTime);
        reservation.setReserveTime(new Date());
        reservation.setStatus(0);
        
        return seatDAO.insertReservation(reservation) > 0;
    }
    
    public boolean checkIn(Integer reservationId) {
        SeatReservation reservation = seatDAO.findReservationById(reservationId);
        if (reservation == null) {
            throw new RuntimeException("预约不存在");
        }
        
        if (reservation.getStatus() != 0) {
            throw new RuntimeException("该预约已处理");
        }
        
        String reserveDate = reservation.getReserveDate();
        String startTime = reservation.getStartTime();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        LocalDateTime startDateTime = LocalDateTime.parse(reserveDate + " " + startTime, formatter);
        LocalDateTime now = LocalDateTime.now();
        
        if (now.isBefore(startDateTime.minusMinutes(30))) {
            throw new RuntimeException("还未到签到时间（提前30分钟开始签到）");
        }
        
        if (now.isAfter(startDateTime.plusMinutes(30))) {
            reservation.setStatus(4);
            seatDAO.updateReservation(reservation);
            seatDAO.insertViolation(reservation.getUserId(), 2, reservationId, "预约未签到");
            throw new RuntimeException("已超过签到时间（迟到30分钟），记录为爽约");
        }
        
        reservation.setCheckinTime(new Date());
        reservation.setStatus(1);
        return seatDAO.updateReservation(reservation) > 0;
    }
    
    public boolean checkOut(Integer reservationId) {
        SeatReservation reservation = seatDAO.findReservationById(reservationId);
        if (reservation == null) {
            throw new RuntimeException("预约不存在");
        }
        
        if (reservation.getStatus() != 1) {
            throw new RuntimeException("未签到，无法签退");
        }
        
        reservation.setCheckoutTime(new Date());
        reservation.setStatus(2);
        return seatDAO.updateReservation(reservation) > 0;
    }
    
    public boolean cancelReservation(Integer reservationId) {
        SeatReservation reservation = seatDAO.findReservationById(reservationId);
        if (reservation == null) {
            throw new RuntimeException("预约不存在");
        }
        
        if (reservation.getStatus() != 0 && reservation.getStatus() != 1) {
            throw new RuntimeException("该预约已处理，无法取消");
        }
        
        reservation.setStatus(3);
        return seatDAO.updateReservation(reservation) > 0;
    }
    
    public List<SeatReservation> getMyReservations(Integer userId) {
        autoCancelExpiredReservations(userId);
        return seatDAO.findReservationsByUserId(userId);
    }
    
    private void autoCancelExpiredReservations(Integer userId) {
        List<SeatReservation> reservations = seatDAO.findReservationsByUserId(userId);
        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        
        for (SeatReservation r : reservations) {
            if (r.getStatus() != null && r.getStatus().equals(0)) {
                String reserveDateTimeStr = r.getReserveDate() + " " + r.getEndTime();
                LocalDateTime reserveEndTime = LocalDateTime.parse(reserveDateTimeStr, formatter);
                
                if (now.isAfter(reserveEndTime)) {
                    r.setStatus(4);
                    seatDAO.updateReservation(r);
                    seatDAO.insertViolation(userId, 2, r.getId(), "预约超时未签到");
                }
            }
        }
    }
    
    public List<SeatReservation> getAllReservations() {
        return seatDAO.findAllReservations();
    }
    
    public SeatReservation getReservationById(Integer id) {
        return seatDAO.findReservationById(id);
    }
    
    public boolean updateSeatStatus(Integer seatId, Integer status) {
        Seat seat = seatDAO.findSeatById(seatId);
        if (seat == null) {
            throw new RuntimeException("座位不存在");
        }
        seat.setStatus(status);
        return seatDAO.updateSeat(seat) > 0;
    }
    
    public boolean addSeat(Seat seat) {
        return seatDAO.insertSeat(seat) > 0;
    }
    
    public boolean deleteSeat(Integer seatId) {
        // 检查是否有未完成的预约
        List<SeatReservation> reservations = seatDAO.findReservationsByUserId(null);
        for (SeatReservation r : reservations) {
            if (r.getSeatId().equals(seatId) && r.getStatus() == 0) {
                throw new RuntimeException("该座位有待完成的预约，无法删除");
            }
        }
        return seatDAO.updateSeatStatus(seatId, 0) > 0;
    }
    
    public boolean handleViolation(Integer violationId, Integer handleBy) {
        return seatDAO.updateViolationStatus(violationId, 1, handleBy) > 0;
    }
}