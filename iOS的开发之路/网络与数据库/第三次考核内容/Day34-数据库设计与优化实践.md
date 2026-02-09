# Day 34：数据库设计与优化实践

## 概述

在掌握 SQLite/FMDB 基础后，本单元侧重**表结构设计**（主键、索引、范式与反范式）、**查询优化**与**迁移思路**（版本号、ALTER/备份重建），并以小型「笔记/列表」为例实践。

## 知识点

### 1. 表结构设计

- **主键**：每表建议有主键（如 INTEGER PRIMARY KEY AUTOINCREMENT），便于唯一标识与关联。
- **索引**：对常出现在 WHERE、ORDER BY、JOIN 条件中的列建索引，可显著加速查询；不宜过多，写多读少时需权衡。
- **范式与反范式**：范式减少冗余、保证一致性；反范式通过适当冗余减少 JOIN、提升查询速度。移动端常采用适度反范式。

### 2. 索引使用与注意

- `CREATE INDEX index_name ON table_name (column);`
- 索引会占用空间并增加写入成本；只对查询频繁的列建索引。
- 避免在索引列上做函数或运算（如 `WHERE LOWER(name)=?` 可能无法用上 name 索引）。

### 3. 简单查询优化

- 只 SELECT 需要的列，避免 `SELECT *`。
- WHERE 条件尽量用索引列。
- 大批量插入使用事务。
- 必要时分页（LIMIT + OFFSET 或游标）避免一次加载过多。

### 4. 迁移思路

- **版本号**：在本地或表中记录 DB 版本（如 user_version）。
- **升级策略**：根据当前版本执行 ALTER TABLE 加列、或创建新表后迁移数据再替换；复杂变更可采用「备份旧表 → 建新表 → 拷贝数据 → 删旧表」。
- SQLite 的 ALTER TABLE 只支持 ADD COLUMN 等有限操作，改类型、删列需通过重建表实现。

## 代码片段说明

- **笔记表设计（含索引）**：见 `NetWork/Examples/Day34_DatabaseDesign/NoteTableManager.h/.m`。
- **查询示例**：带索引列的 WHERE、按需 SELECT。
- **简单迁移**：版本 1 → 2 增加字段，见 `NoteTableManager` 内 migration 逻辑。

## 注意事项 / 常见坑

- 新增索引前可先分析慢查询，避免盲目加索引。
- 迁移时做好备份或仅在测试环境验证后再发布。
- 多端（iOS/Android）若共用同一套表结构，需约定好版本与迁移顺序。

## 小结

- 主键与合理索引是设计基础；查询写法和迁移策略决定长期可维护性。
- 配套示例提供「笔记表」完整建表、索引与简单迁移，可直接扩展。

配套示例路径：`NetWork/Examples/Day34_DatabaseDesign/`。
