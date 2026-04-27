// service/BookService.java
package com.library.service;

import com.library.dao.BookDAO;
import com.library.model.Book;
import com.library.model.BookCategory;

import java.util.List;

public class BookService {
    private BookDAO bookDAO = new BookDAO();
    
    public List<Book> searchBooks(String keyword, String type, Integer categoryId) {
        return bookDAO.search(keyword, type, categoryId);
    }
    
    public Book getBookDetail(Integer bookId) {
        return bookDAO.findById(bookId);
    }
    
    public List<Book> getNewBooks(int limit) {
        return bookDAO.findNewBooks(limit);
    }
    
    public List<Book> getHotBooks(int limit) {
        return bookDAO.findHotBooks(limit);
    }
    
    public List<Book> getRecommendBooks(Integer userId, int limit) {
        if (userId == null) {
            return getNewBooks(limit);
        }
        return bookDAO.findRecommendByUserId(userId, limit);
    }
    
    public boolean addBook(Book book) {
        Book existing = bookDAO.findByIsbn(book.getIsbn());
        if (existing != null) {
            throw new RuntimeException("ISBN已存在");
        }
        book.setStatus(1);
        return bookDAO.insert(book) > 0;
    }
    
    public boolean updateBook(Book book) {
        return bookDAO.update(book) > 0;
    }
    
    public boolean removeBook(Integer bookId) {
        Book book = bookDAO.findById(bookId);
        if (book == null) {
            throw new RuntimeException("图书不存在");
        }
        List<?> borrowingRecords = bookDAO.findBorrowingRecords(bookId);
        if (!borrowingRecords.isEmpty()) {
            throw new RuntimeException("该图书还有未归还的借阅记录，无法下架");
        }
        book.setStatus(0);
        return bookDAO.update(book) > 0;
    }
    
    public boolean restoreBook(Integer bookId) {
        Book book = bookDAO.findById(bookId);
        if (book == null) {
            throw new RuntimeException("图书不存在");
        }
        book.setStatus(1);
        return bookDAO.update(book) > 0;
    }
    
    public List<BookCategory> getAllCategories() {
        return bookDAO.findAllCategories();
    }
    
    public boolean addCategory(BookCategory category) {
        return bookDAO.insertCategory(category) > 0;
    }
    
    public boolean updateCategory(BookCategory category) {
        return bookDAO.updateCategory(category) > 0;
    }
    
    public boolean deleteCategory(Integer id) {
        return bookDAO.deleteCategory(id) > 0;
    }
}