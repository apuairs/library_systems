package com.library.model;

public class BookCategory {
    private Integer id;
    private String name;
    private Integer parentId;
    private Integer sortOrder;
    private Integer bookCount;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public Integer getParentId() { return parentId; }
    public void setParentId(Integer parentId) { this.parentId = parentId; }
    public Integer getSortOrder() { return sortOrder; }
    public void setSortOrder(Integer sortOrder) { this.sortOrder = sortOrder; }
    public Integer getBookCount() { return bookCount; }
    public void setBookCount(Integer bookCount) { this.bookCount = bookCount; }
}