package com.library.model;

import java.util.Date;

public class Book {
    private Integer id;
    private String isbn;
    private String title;
    private String author;
    private String publisher;
    private Date publishDate;
    private Integer categoryId;
    private String categoryName;
    private String description;
    private String coverUrl;
    private Integer totalCount;
    private Integer availableCount;
    private String location;
    private String shelfNumber;
    private Integer status;    // 0-下架, 1-上架
    private Date createTime;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public String getIsbn() { return isbn; }
    public void setIsbn(String isbn) { this.isbn = isbn; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }
    public String getPublisher() { return publisher; }
    public void setPublisher(String publisher) { this.publisher = publisher; }
    public Date getPublishDate() { return publishDate; }
    public void setPublishDate(Date publishDate) { this.publishDate = publishDate; }
    public Integer getCategoryId() { return categoryId; }
    public void setCategoryId(Integer categoryId) { this.categoryId = categoryId; }
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getCoverUrl() { return coverUrl; }
    public void setCoverUrl(String coverUrl) { this.coverUrl = coverUrl; }
    public Integer getTotalCount() { return totalCount; }
    public void setTotalCount(Integer totalCount) { this.totalCount = totalCount; }
    public Integer getAvailableCount() { return availableCount; }
    public void setAvailableCount(Integer availableCount) { this.availableCount = availableCount; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public String getShelfNumber() { return shelfNumber; }
    public void setShelfNumber(String shelfNumber) { this.shelfNumber = shelfNumber; }
    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }
    
    public boolean isAvailable() {
        return status == 1 && availableCount != null && availableCount > 0;
    }
    
    public String getStatusText() {
        if (status == 0) return "已下架";
        return isAvailable() ? "可借" : "已借出";
    }
}