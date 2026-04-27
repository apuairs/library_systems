package com.library.util;

import java.util.List;

public class PageUtil<T> {
    private int currentPage;    // 当前页
    private int pageSize;       // 每页记录数
    private int totalCount;     // 总记录数
    private int totalPages;     // 总页数
    private List<T> data;       // 当前页数据
    
    public PageUtil(int currentPage, int pageSize, int totalCount, List<T> data) {
        this.currentPage = currentPage;
        this.pageSize = pageSize;
        this.totalCount = totalCount;
        this.data = data;
        this.totalPages = (int) Math.ceil((double) totalCount / pageSize);
    }
    
    public int getCurrentPage() { return currentPage; }
    public int getPageSize() { return pageSize; }
    public int getTotalCount() { return totalCount; }
    public int getTotalPages() { return totalPages; }
    public List<T> getData() { return data; }
    public boolean hasPrev() { return currentPage > 1; }
    public boolean hasNext() { return currentPage < totalPages; }
    public int getPrevPage() { return currentPage - 1; }
    public int getNextPage() { return currentPage + 1; }
}