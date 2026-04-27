// servlet/SearchBookServlet.java
package com.library.servlet;

import com.library.model.Book;
import com.library.service.BookService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import com.fasterxml.jackson.databind.ObjectMapper;

@WebServlet("/searchBook")
public class SearchBookServlet extends HttpServlet {
    
    private BookService bookService = new BookService();
    private ObjectMapper objectMapper = new ObjectMapper();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        String searchType = req.getParameter("type");
        String categoryIdStr = req.getParameter("categoryId");
        String pageStr = req.getParameter("page");
        
        Integer categoryId = null;
        if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
            categoryId = Integer.parseInt(categoryIdStr);
        }
        
        int page = 1;
        if (pageStr != null && !pageStr.isEmpty()) {
            page = Integer.parseInt(pageStr);
        }
        int pageSize = 12;
        
        List<Book> books = bookService.searchBooks(keyword, searchType, categoryId);
        
        // 分页处理
        int totalCount = books.size();
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        int start = (page - 1) * pageSize;
        int end = Math.min(start + pageSize, totalCount);
        List<Book> pageBooks = books.subList(start, end);
        
        // 检查是否需要返回JSON
        String acceptHeader = req.getHeader("Accept");
        if (acceptHeader != null && acceptHeader.contains("application/json")) {
            // 返回JSON格式
            Map<String, Object> response = new HashMap<>();
            response.put("books", pageBooks);
            response.put("totalPages", totalPages);
            response.put("currentPage", page);
            response.put("totalCount", totalCount);
            
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            objectMapper.writeValue(resp.getOutputStream(), response);
        } else {
            // 返回JSP页面
            req.setAttribute("books", pageBooks);
            req.setAttribute("keyword", keyword);
            req.setAttribute("searchType", searchType);
            req.setAttribute("categoryId", categoryId);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("totalCount", totalCount);
            
            req.getRequestDispatcher("/user/search_result.jsp").forward(req, resp);
        }
    }
}