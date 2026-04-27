package com.library.dao;

import com.library.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public abstract class BaseDAO<T> {
    
    protected abstract T mapRow(ResultSet rs) throws SQLException;
    
    protected List<T> query(String sql, Object... params) {
        List<T> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            setParameters(ps, params);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }
    
    protected T queryOne(String sql, Object... params) {
        List<T> list = query(sql, params);
        return list.isEmpty() ? null : list.get(0);
    }
    
    protected int update(String sql, Object... params) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            setParameters(ps, params);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        } finally {
            DBUtil.close(conn, ps);
        }
    }
    
    protected int insertAndGetId(String sql, Object... params) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            setParameters(ps, params);
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
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
    
    private void setParameters(PreparedStatement ps, Object... params) throws SQLException {
        if (params != null) {
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
        }
    }
}