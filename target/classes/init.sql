-- =============================================
-- 图书馆管理系统数据库初始化脚本
-- 执行顺序：先创建数据库，再执行此脚本
-- =============================================

-- 创建数据库（如果不存在）
-- CREATE DATABASE IF NOT EXISTS library_system DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE library_system;

-- ---------------------------------------------
-- 1. 用户表 user
-- ---------------------------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
    `id` INT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `username` VARCHAR(50) NOT NULL COMMENT '用户名/学号',
    `password` VARCHAR(64) NOT NULL COMMENT '密码（MD5加密）',
    `name` VARCHAR(50) NOT NULL COMMENT '真实姓名',
    `phone` VARCHAR(20) COMMENT '手机号',
    `email` VARCHAR(100) COMMENT '邮箱',
    `role` TINYINT DEFAULT 0 COMMENT '角色：0-普通用户，1-管理员',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-冻结，1-正常，2-待审核',
    `violation_count` INT DEFAULT 0 COMMENT '违规次数',
    `frozen_until` DATETIME COMMENT '冻结至',
    `create_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 插入默认账号
-- 密码 123456 的 MD5 加密值：e10adc3949ba59abbe56e057f20f883e
INSERT INTO `user` (`username`, `password`, `name`, `phone`, `email`, `role`, `status`, `violation_count`)
VALUES 
('admin', 'e10adc3949ba59abbe56e057f20f883e', '系统管理员', '13800138000', 'admin@library.com', 1, 1, 0),
('test', 'e10adc3949ba59abbe56e057f20f883e', '测试用户', '13800138001', 'test@library.com', 0, 1, 0);

-- ---------------------------------------------
-- 2. 图书分类表 book_category
-- ---------------------------------------------
DROP TABLE IF EXISTS `book_category`;
CREATE TABLE `book_category` (
    `id` INT NOT NULL AUTO_INCREMENT COMMENT '分类ID',
    `name` VARCHAR(100) NOT NULL COMMENT '分类名称',
    `code` VARCHAR(50) NOT NULL COMMENT '分类编码',
    `parent_id` INT DEFAULT 0 COMMENT '父分类ID',
    `sort` INT DEFAULT 0 COMMENT '排序',
    `create_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='图书分类表';

-- 插入默认分类
INSERT INTO `book_category` (`name`, `code`, `parent_id`, `sort`) VALUES
('文学小说', 'LITERATURE', 0, 1),
('计算机科学', 'COMPUTER', 0, 2),
('经济管理', 'ECONOMY', 0, 3),
('外语学习', 'LANGUAGE', 0, 4),
('自然科学', 'SCIENCE', 0, 5),
('工程技术', 'ENGINEER', 0, 6),
('历史地理', 'HISTORY', 0, 7),
('哲学艺术', 'PHILOSOPHY', 0, 8);

-- ---------------------------------------------
-- 3. 图书表 book
-- ---------------------------------------------
DROP TABLE IF EXISTS `book`;
CREATE TABLE `book` (
    `id` INT NOT NULL AUTO_INCREMENT COMMENT '图书ID',
    `isbn` VARCHAR(20) COMMENT 'ISBN号',
    `name` VARCHAR(200) NOT NULL COMMENT '书名',
    `author` VARCHAR(100) COMMENT '作者',
    `publisher` VARCHAR(100) COMMENT '出版社',
    `publish_date` DATE COMMENT '出版日期',
    `category_id` INT COMMENT '分类ID',
    `price` DECIMAL(10,2) COMMENT '价格',
    `quantity` INT DEFAULT 1 COMMENT '总数量',
    `available` INT DEFAULT 1 COMMENT '可借数量',
    `location` VARCHAR(100) COMMENT '馆藏位置',
    `description` TEXT COMMENT '内容简介',
    `cover` VARCHAR(200) COMMENT '封面图片',
    `create_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_category` (`category_id`),
    KEY `idx_name` (`name`),
    KEY `idx_author` (`author`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='图书表';

-- 插入测试图书
INSERT INTO `book` (`isbn`, `name`, `author`, `publisher`, `category_id`, `price`, `quantity`, `available`, `location`, `description`)
VALUES 
('9787115428029', 'Java编程思想', 'Bruce Eckel', '机械工业出版社', 2, 108.00, 10, 10, 'A区-01架-02层', 'Java学习经典著作，全面介绍Java编程'),
('9787302275167', '深入理解计算机系统', 'Randal E.Bryant', '清华大学出版社', 2, 139.00, 5, 5, 'A区-01架-03层', '从程序员角度理解计算机系统'),
('9787020104235', '百年孤独', '加西亚·马尔克斯', '人民文学出版社', 1, 39.50, 15, 15, 'B区-01架-01层', '魔幻现实主义文学代表作'),
('9787111213826', '算法导论', 'Thomas H.Cormen', '机械工业出版社', 2, 128.00, 8, 8, 'A区-02架-01层', '算法领域经典教材'),
('9787508647357', '经济学原理', '曼昆', '北京大学出版社', 3, 79.00, 12, 12, 'C区-01架-01层', '经济学入门经典教材'),
('9787560013428', '新概念英语', '亚历山大', '外语教学与研究出版社', 4, 32.00, 20, 20, 'D区-01架-01层', '经典英语学习教材'),
('9787020024759', '红楼梦', '曹雪芹', '人民文学出版社', 1, 59.80, 10, 10, 'B区-02架-01层', '中国古典文学四大名著之一'),
('9787111333499', 'Python编程：从入门到实践', 'Eric Matthes', '机械工业出版社', 2, 89.00, 12, 12, 'A区-01架-04层', 'Python入门最佳教程');

-- ---------------------------------------------
-- 4. 借阅记录表 borrow_record
-- ---------------------------------------------
DROP TABLE IF EXISTS `borrow_record`;
CREATE TABLE `borrow_record` (
    `id` INT NOT NULL AUTO_INCREMENT COMMENT '记录ID',
    `user_id` INT NOT NULL COMMENT '用户ID',
    `book_id` INT NOT NULL COMMENT '图书ID',
    `borrow_date` DATE NOT NULL COMMENT '借阅日期',
    `due_date` DATE NOT NULL COMMENT '应还日期',
    `return_date` DATE COMMENT '实际归还日期',
    `renew_count` INT DEFAULT 0 COMMENT '续借次数',
    `status` TINYINT DEFAULT 0 COMMENT '状态：0-借阅中，1-已归还，2-已逾期',
    `create_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_user` (`user_id`),
    KEY `idx_book` (`book_id`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='借阅记录表';

-- ---------------------------------------------
-- 5. 预约记录表 reservation
-- ---------------------------------------------
DROP TABLE IF EXISTS `reservation`;
CREATE TABLE `reservation` (
    `id` INT NOT NULL AUTO_INCREMENT COMMENT '预约ID',
    `user_id` INT NOT NULL COMMENT '用户ID',
    `book_id` INT NOT NULL COMMENT '图书ID',
    `reserve_date` DATE NOT NULL COMMENT '预约日期',
    `expire_date` DATE NOT NULL COMMENT '过期日期',
    `status` TINYINT DEFAULT 0 COMMENT '状态：0-等待中，1-已通知，2-已取消，3-已完成',
    `create_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_user` (`user_id`),
    KEY `idx_book` (`book_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预约记录表';

-- ---------------------------------------------
-- 6. 座位表 seat
-- ---------------------------------------------
DROP TABLE IF EXISTS `seat`;
CREATE TABLE `seat` (
    `id` INT NOT NULL AUTO_INCREMENT COMMENT '座位ID',
    `floor` INT NOT NULL COMMENT '楼层',
    `area` VARCHAR(50) COMMENT '区域',
    `seat_number` VARCHAR(20) NOT NULL COMMENT '座位编号',
    `status` TINYINT DEFAULT 0 COMMENT '状态：0-空闲，1-已预约，2-使用中',
    `create_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_seat` (`floor`, `area`, `seat_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='座位表';

-- 插入测试座位
INSERT INTO `seat` (`floor`, `area`, `seat_number`, `status`) VALUES
(1, 'A区', 'A1-001', 0), (1, 'A区', 'A1-002', 0), (1, 'A区', 'A1-003', 0),
(1, 'A区', 'A1-004', 0), (1, 'A区', 'A1-005', 0),
(1, 'B区', 'B1-001', 0), (1, 'B区', 'B1-002', 0), (1, 'B区', 'B1-003', 0),
(2, 'A区', 'A2-001', 0), (2, 'A区', 'A2-002', 0), (2, 'A区', 'A2-003', 0),
(2, 'B区', 'B2-001', 0), (2, 'B区', 'B2-002', 0), (2, 'B区', 'B2-003', 0),
(3, 'A区', 'A3-001', 0), (3, 'A区', 'A3-002', 0),
(3, '自习区', 'S3-001', 0), (3, '自习区', 'S3-002', 0), (3, '自习区', 'S3-003', 0),
(3, '自习区', 'S3-004', 0), (3, '自习区', 'S3-005', 0);

-- ---------------------------------------------
-- 7. 座位预约表 seat_reservation
-- ---------------------------------------------
DROP TABLE IF EXISTS `seat_reservation`;
CREATE TABLE `seat_reservation` (
    `id` INT NOT NULL AUTO_INCREMENT COMMENT '预约ID',
    `user_id` INT NOT NULL COMMENT '用户ID',
    `seat_id` INT NOT NULL COMMENT '座位ID',
    `reserve_date` DATE NOT NULL COMMENT '预约日期',
    `start_time` TIME NOT NULL COMMENT '开始时间',
    `end_time` TIME NOT NULL COMMENT '结束时间',
    `check_in_time` DATETIME COMMENT '签到时间',
    `check_out_time` DATETIME COMMENT '签退时间',
    `status` TINYINT DEFAULT 0 COMMENT '状态：0-已预约，1-已签到，2-已完成，3-已取消，4-已违约',
    `create_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_user` (`user_id`),
    KEY `idx_seat` (`seat_id`),
    KEY `idx_date` (`reserve_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='座位预约表';

-- ---------------------------------------------
-- 8. 违规记录表 violation
-- ---------------------------------------------
DROP TABLE IF EXISTS `violation`;
CREATE TABLE `violation` (
    `id` INT NOT NULL AUTO_INCREMENT COMMENT '记录ID',
    `user_id` INT NOT NULL COMMENT '用户ID',
    `type` TINYINT NOT NULL COMMENT '类型：1-图书逾期，2-图书损坏，3-座位违约，4-其他',
    `related_id` INT COMMENT '关联ID（借阅记录ID/座位预约ID）',
    `reason` VARCHAR(500) COMMENT '违规原因',
    `handle_status` TINYINT DEFAULT 0 COMMENT '处理状态：0-未处理，1-已处理',
    `handle_by` INT COMMENT '处理人',
    `handle_note` VARCHAR(500) COMMENT '处理备注',
    `handle_time` DATETIME COMMENT '处理时间',
    `create_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_user` (`user_id`),
    KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='违规记录表';

-- ---------------------------------------------
-- 9. 系统配置表 sys_config
-- ---------------------------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `config_key` VARCHAR(100) NOT NULL COMMENT '配置键',
    `config_value` VARCHAR(500) NOT NULL COMMENT '配置值',
    `description` VARCHAR(200) COMMENT '配置说明',
    `create_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `update_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_config_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统配置表';

-- 插入默认配置
INSERT INTO `sys_config` (`config_key`, `config_value`, `description`) VALUES
('borrow.max_books', '10', '每人最大借阅数量'),
('borrow.days', '30', '借阅期限（天）'),
('borrow.renew_times', '2', '最大续借次数'),
('reserve.expire_days', '3', '预约保留天数'),
('seat.max_reserve_days', '7', '座位最长预约天数'),
('violation.max_count', '5', '最大违规次数（冻结阈值）');

-- ---------------------------------------------
-- 初始化完成
-- ---------------------------------------------
SELECT '数据库初始化完成！' AS message;
SELECT '默认账号：admin / 123456 (管理员)' AS info;
SELECT '默认账号：test / 123456 (普通用户)' AS info;
