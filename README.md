# SQL
 >基础语法  

使用数据库为test2


#### MySql 命令行实用程序
`mysql -u username -p`  
`mysql --help`

选择数据库  
`SHOW DATABASES;`  
`USE DBNAME;`  
`SHOW TABLES;`  
`SHOW COLUMNS FROM DATABASES;`  OR `DESCRIBE DATABASES;`  

检索数据  
`SELECT prod_name FROM products;` #检索单列  
`SELECT prod_id,prod_name,  prod_price
FROM products;` #检索多列
