# SQL
 >基础语法  

使用数据库为test2


#### MySql 命令行实用程序
`mysql -u username -p`  
`mysql --help`

#### 选择数据库  
`SHOW DATABASES;`  
`USE DBNAME;`  
`SHOW TABLES;`  
`SHOW COLUMNS FROM DATABASES;`  OR `DESCRIBE DATABASES;`  

#### 检索数据  
`SELECT prod_name FROM products;`   #检索单列  
`SELECT prod_id,prod_name,  prod_price
FROM products;`   #检索多列  
`SELECT DISTINCT vend_id
FROM products;`   #检索不同的行，但不能部分使用distinct  
`SELECT prod_id
FROM products
LIMIT 3;`   #限制结果

#### 排序检索数据  
`SELECT prod_name
FROM products
ORDER BY prod_name;` #也可多列排序，并指定排序方向DESC,默认为ASC  

#### 过滤数据  
`SELECT prod_name, prod_price
FROM products
WHERE prod_price = 2.50;`  
>范围值检查 `BETWEEN`
空值检查`IS NULL`  
组合WHERE子句 `AND` `OR` 优先处理`AND`  

```
# IN 操作符
SELECT prod_name, prod_price
FROM products  
WHERE vend_id IN (1002,1003)   
ORDER BY prod_name;  
```  
```
# NOT 操作符
SELECT prod_name, prod_price
FROM products  
WHERE vend_id NOT IN (1002,1003)   
ORDER BY prod_name;  
```
>MySql支持NOT对IN，BETWEEN，EXISTS子句取反

```
#使用通配符（wildcard）进行过滤,%匹配0个或多个字符，而_只匹配一个字符
SELECT prod_id, prod_name
FROM products
WHERE prod_name LIKE 'jet%';  

SELECT prod_id, prod_name
FROM products
WHERE prod_name LIKE '- ton anvil';
```  
#### 创建计算字段  
```
#使用contact函数拼接字段，并使用别名
SELECT CONCAT(vend_name,vend_country) as vend_title
FROM vendors
ORDER BY vend_name;
```  
```
#执行算术计算，并使用别名
SELECT quantity * item_price as expand_price
FROM orderitems
WHERE order_num = 20005;
```
