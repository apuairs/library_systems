DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `username` VARCHAR(50) NOT NULL,
    `password` VARCHAR(64) NOT NULL,
    `name` VARCHAR(50) NOT NULL,
    `phone` VARCHAR(20),
    `email` VARCHAR(100),
    `role` TINYINT DEFAULT 0,
    `status` TINYINT DEFAULT 1,
    `violation_count` INT DEFAULT 0,
    `frozen_until` DATETIME,
    `create_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `update_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `user` (`username`, `password`, `name`, `phone`, `email`, `role`, `status`, `violation_count`)
VALUES 
('admin', 'e10adc3949ba59abbe56e057f20f883e', 'Admin', '13800138000', 'admin@library.com', 1, 1, 0),
('test', 'e10adc3949ba59abbe56e057f20f883e', 'Test User', '13800138001', 'test@library.com', 0, 1, 0);

DROP TABLE IF EXISTS `book_category`;
CREATE TABLE `book_category` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `code` VARCHAR(50) NOT NULL,
    `parent_id` INT DEFAULT 0,
    `sort` INT DEFAULT 0,
    `create_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `book_category` (`name`, `code`, `parent_id`, `sort`) VALUES
('Literature', 'LITERATURE', 0, 1),
('Computer', 'COMPUTER', 0, 2),
('Economy', 'ECONOMY', 0, 3),
('Language', 'LANGUAGE', 0, 4),
('Science', 'SCIENCE', 0, 5),
('Engineering', 'ENGINEER', 0, 6),
('History', 'HISTORY', 0, 7),
('Philosophy', 'PHILOSOPHY', 0, 8);

DROP TABLE IF EXISTS `book`;
CREATE TABLE `book` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `isbn` VARCHAR(20),
    `title` VARCHAR(200) NOT NULL,
    `author` VARCHAR(100),
    `publisher` VARCHAR(100),
    `publish_date` DATE,
    `category_id` INT,
    `price` DECIMAL(10,2),
    `total_count` INT DEFAULT 1,
    `available_count` INT DEFAULT 1,
    `location` VARCHAR(100),
    `description` TEXT,
    `cover_url` VARCHAR(200),
    `status` INT DEFAULT 1,
    `create_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `update_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_category` (`category_id`),
    KEY `idx_name` (`title`),
    KEY `idx_author` (`author`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `book` (`isbn`, `title`, `author`, `publisher`, `category_id`, `price`, `total_count`, `available_count`, `location`, `description`, `status`)
VALUES 
('9787115428029', 'Java Programming', 'Bruce Eckel', 'Machine Press', 2, 108.00, 10, 10, 'A-01-02', 'Java learning book', 1),
('9787302275167', 'Computer Systems', 'Randal E.Bryant', 'Tsinghua Press', 2, 139.00, 5, 5, 'A-01-03', 'Computer systems', 1),
('9787020104235', 'One Hundred Years', 'García Márquez', 'Literature Press', 1, 39.50, 15, 15, 'B-01-01', 'Classic literature', 1),
('9787111213826', 'Algorithm', 'Thomas H.Cormen', 'Machine Press', 2, 128.00, 8, 8, 'A-02-01', 'Algorithm book', 1),
('9787508647357', 'Economics', 'Mankiw', 'Peking Press', 3, 79.00, 12, 12, 'C-01-01', 'Economics book', 1),
('9787560013428', 'New Concept English', 'Alexander', 'Foreign Press', 4, 32.00, 20, 20, 'D-01-01', 'English learning', 1),
('9787020024759', 'Dream of Red', 'Cao Xueqin', 'Literature Press', 1, 59.80, 10, 10, 'B-02-01', 'Chinese classic', 1),
('9787111333499', 'Python', 'Eric Matthes', 'Machine Press', 2, 89.00, 12, 12, 'A-01-04', 'Python learning', 1);

DROP TABLE IF EXISTS `borrow_record`;
CREATE TABLE `borrow_record` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `book_id` INT NOT NULL,
    `borrow_date` DATE NOT NULL,
    `due_date` DATE NOT NULL,
    `return_date` DATE,
    `renew_count` INT DEFAULT 0,
    `status` INT DEFAULT 0,
    `create_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `update_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user` (`user_id`),
    KEY `idx_book` (`book_id`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `seat`;
CREATE TABLE `seat` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `floor` INT NOT NULL,
    `area` VARCHAR(50),
    `seat_number` VARCHAR(20) NOT NULL,
    `status` INT DEFAULT 0,
    `create_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_seat` (`floor`, `area`, `seat_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `seat` (`floor`, `area`, `seat_number`, `status`) VALUES
(1, 'A', 'A1-001', 0), (1, 'A', 'A1-002', 0), (1, 'A', 'A1-003', 0),
(1, 'A', 'A1-004', 0), (1, 'A', 'A1-005', 0),
(1, 'B', 'B1-001', 0), (1, 'B', 'B1-002', 0), (1, 'B', 'B1-003', 0),
(2, 'A', 'A2-001', 0), (2, 'A', 'A2-002', 0), (2, 'A', 'A2-003', 0),
(2, 'B', 'B2-001', 0), (2, 'B', 'B2-002', 0), (2, 'B', 'B2-003', 0),
(3, 'A', 'A3-001', 0), (3, 'A', 'A3-002', 0),
(3, 'Study', 'S3-001', 0), (3, 'Study', 'S3-002', 0), (3, 'Study', 'S3-003', 0),
(3, 'Study', 'S3-004', 0), (3, 'Study', 'S3-005', 0);

DROP TABLE IF EXISTS `seat_reservation`;
CREATE TABLE `seat_reservation` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `seat_id` INT NOT NULL,
    `reserve_date` DATE NOT NULL,
    `start_time` TIME NOT NULL,
    `end_time` TIME NOT NULL,
    `check_in_time` DATETIME,
    `check_out_time` DATETIME,
    `status` INT DEFAULT 0,
    `create_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user` (`user_id`),
    KEY `idx_seat` (`seat_id`),
    KEY `idx_date` (`reserve_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `notice`;
CREATE TABLE `notice` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(200) NOT NULL,
    `content` TEXT NOT NULL,
    `status` INT DEFAULT 1,
    `create_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `notice` (`title`, `content`, `status`) VALUES
('Welcome', 'Welcome to the library system!', 1),
('Opening Hours', 'Monday - Sunday: 8:00 - 22:00', 1);
