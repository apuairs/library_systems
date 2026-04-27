// dao/BookDAO.java
package com.library.dao;

import com.library.model.Book;
import com.library.model.BookCategory;
import com.library.model.BorrowRecord;
import com.library.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookDAO extends BaseDAO<Book> {
    
    @Override
    protected Book mapRow(ResultSet rs) throws SQLException {
        Book book = new Book();
        book.setId(rs.getInt("id"));
        book.setIsbn(rs.getString("isbn"));
        book.setTitle(rs.getString("title"));
        book.setAuthor(rs.getString("author"));
        book.setPublisher(rs.getString("publisher"));
        book.setPublishDate(rs.getDate("publish_date"));
        book.setCategoryId(rs.getInt("category_id"));
        
        // 使用 columnLabel 来获取别名(category_name)
        try {
            book.setCategoryName(rs.getString("category_name"));
        } catch (SQLException e) {
            // 如果没有 category_name 字段，尝试用 name
            try {
                book.setCategoryName(rs.getString("name"));
            } catch (SQLException e2) {
                book.setCategoryName(null);
            }
        }
        
        book.setDescription(rs.getString("description"));
        book.setCoverUrl(rs.getString("cover_url"));
        book.setTotalCount(rs.getInt("total_count"));
        book.setAvailableCount(rs.getInt("available_count"));
        book.setLocation(rs.getString("location"));
        
        // shelf_number 可能不存在
        try {
            book.setShelfNumber(rs.getString("shelf_number"));
        } catch (SQLException e) {
            book.setShelfNumber(null);
        }
        
        book.setStatus(rs.getInt("status"));
        book.setCreateTime(rs.getTimestamp("create_time"));
        return book;
    }
    
    public Book findById(Integer id) {
        String sql = "SELECT b.*, c.name as category_name FROM book b " +
                     "LEFT JOIN book_category c ON b.category_id = c.id " +
                     "WHERE b.id = ?";
        return queryOne(sql, id);
    }
    
    public Book findByIsbn(String isbn) {
        String sql = "SELECT b.*, c.name as category_name FROM book b " +
                     "LEFT JOIN book_category c ON b.category_id = c.id " +
                     "WHERE b.isbn = ?";
        return queryOne(sql, isbn);
    }
    
    public List<Book> search(String keyword, String type, Integer categoryId) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT b.*, c.name as category_name FROM book b ");
        sql.append("LEFT JOIN book_category c ON b.category_id = c.id ");
        sql.append("WHERE b.status = 1 ");
        
        List<Object> params = new ArrayList<>();
        
        if (keyword != null && !keyword.isEmpty()) {
            if ("isbn".equals(type)) {
                sql.append("AND b.isbn LIKE ? ");
                params.add("%" + keyword + "%");
            } else if ("author".equals(type)) {
                sql.append("AND b.author LIKE ? ");
                params.add("%" + keyword + "%");
            } else {
                sql.append("AND (b.title LIKE ? OR b.author LIKE ? OR b.isbn LIKE ?) ");
                params.add("%" + keyword + "%");
                params.add("%" + keyword + "%");
                params.add("%" + keyword + "%");
            }
        }
        
        if (categoryId != null && categoryId > 0) {
            sql.append("AND b.category_id = ? ");
            params.add(categoryId);
        }
        
        sql.append("ORDER BY b.create_time DESC");
        
        return query(sql.toString(), params.toArray());
    }
    
    public List<Book> findNewBooks(int limit) {
        String sql = "SELECT b.*, c.name as category_name FROM book b " +
                     "LEFT JOIN book_category c ON b.category_id = c.id " +
                     "WHERE b.status = 1 " +
                     "ORDER BY b.create_time DESC LIMIT ?";
        return query(sql, limit);
    }
    
    public List<Book> findHotBooks(int limit) {
        String sql = "SELECT b.*, c.name as category_name, COUNT(br.id) as borrow_count " +
                     "FROM book b " +
                     "LEFT JOIN book_category c ON b.category_id = c.id " +
                     "LEFT JOIN borrow_record br ON b.id = br.book_id " +
                     "WHERE b.status = 1 " +
                     "GROUP BY b.id " +
                     "ORDER BY borrow_count DESC LIMIT ?";
        return query(sql, limit);
    }
    
    public List<Book> findRecommendByUserId(Integer userId, int limit) {
        String sql = "SELECT DISTINCT b.*, c.name as category_name FROM book b " +
                     "LEFT JOIN book_category c ON b.category_id = c.id " +
                     "WHERE b.category_id IN ( " +
                     "    SELECT DISTINCT category_id FROM borrow_record br " +
                     "    JOIN book bk ON br.book_id = bk.id " +
                     "    WHERE br.user_id = ? " +
                     ") AND b.status = 1 AND b.id NOT IN ( " +
                     "    SELECT book_id FROM borrow_record WHERE user_id = ? AND status != 1 " +
                     ") LIMIT ?";
        return query(sql, userId, userId, limit);
    }
    
    public int insert(Book book) {
        String sql = "INSERT INTO book (isbn, title, author, publisher, publish_date, category_id, " +
                     "description, cover_url, total_count, available_count, location, shelf_number, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        return update(sql, book.getIsbn(), book.getTitle(), book.getAuthor(), book.getPublisher(),
                book.getPublishDate(), book.getCategoryId(), book.getDescription(), book.getCoverUrl(),
                book.getTotalCount(), book.getAvailableCount(), book.getLocation(), book.getShelfNumber(),
                book.getStatus());
    }
    
    public int update(Book book) {
        String sql = "UPDATE book SET title=?, author=?, publisher=?, publish_date=?, category_id=?, " +
                     "description=?, cover_url=?, total_count=?, available_count=?, location=?, shelf_number=?, status=? " +
                     "WHERE id=?";
        return update(sql, book.getTitle(), book.getAuthor(), book.getPublisher(), book.getPublishDate(),
                book.getCategoryId(), book.getDescription(), book.getCoverUrl(), book.getTotalCount(),
                book.getAvailableCount(), book.getLocation(), book.getShelfNumber(), book.getStatus(), book.getId());
    }
    
    public int updateAvailableCount(Integer bookId, int change) {
        String sql = "UPDATE book SET available_count = available_count + ? WHERE id = ?";
        return update(sql, change, bookId);
    }
    
    public List<BorrowRecord> findBorrowingRecords(Integer bookId) {
        String sql = "SELECT * FROM borrow_record WHERE book_id = ? AND status != 1";
        List<BorrowRecord> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, bookId);
            rs = ps.executeQuery();
            while (rs.next()) {
                BorrowRecord record = new BorrowRecord();
                record.setId(rs.getInt("id"));
                list.add(record);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }
    
    public List<BookCategory> findAllCategories() {
        String sql = "SELECT * FROM book_category ORDER BY sort_order, id";
        List<BookCategory> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                BookCategory c = new BookCategory();
                c.setId(rs.getInt("id"));
                c.setName(rs.getString("name"));
                c.setParentId(rs.getInt("parent_id"));
                c.setSortOrder(rs.getInt("sort_order"));
                list.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }
    
    public int insertCategory(BookCategory category) {
        String sql = "INSERT INTO book_category (name, parent_id, sort_order) VALUES (?, ?, ?)";
        return update(sql, category.getName(), category.getParentId(), category.getSortOrder());
    }
    
    public int updateCategory(BookCategory category) {
        String sql = "UPDATE book_category SET name=?, sort_order=? WHERE id=?";
        return update(sql, category.getName(), category.getSortOrder(), category.getId());
    }
    
    public int deleteCategory(Integer id) {
        String sql = "DELETE FROM book_category WHERE id=?";
        return update(sql, id);
    }
}