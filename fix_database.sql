-- 修复 borrow_record 表结构
-- 执行此脚本修复缺失的字段

USE library_system;

-- 添加缺失的字段
ALTER TABLE borrow_record 
ADD COLUMN IF NOT EXISTS operator_id INT COMMENT '操作人ID' AFTER status;

ALTER TABLE borrow_record 
ADD COLUMN IF NOT EXISTS fine_amount DECIMAL(10,2) DEFAULT 0 COMMENT '罚款金额' AFTER operator_id;

-- 验证表结构
DESC borrow_record;

SELECT '表结构修复完成！' AS message;
