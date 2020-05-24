# SQL
 >基础语法  

使用数据库为test2


#### MySql 命令行实用程序
`mysql -u username -p`
`mysql --help`

#### 创建和操纵表
```
CREATE TABLE customers (
  cust_id int(11) NOT NULL AUTO_INCREMENT,
  cust_name char(50) NOT NULL,
  cust_address char(50) DEFAULT NULL,
  cust_city char(50) DEFAULT NULL,
  cust_state char(5) DEFAULT NULL,
  cust_zip char(10) DEFAULT NULL,
  cust_country char(50) DEFAULT NULL,
  cust_contact char(50) DEFAULT NULL,
  cust_email char(255) DEFAULT NULL,
  PRIMARY KEY (cust_id)
) ENGINE=InnoDB AUTO_INCREMENT=10007 DEFAULT CHARSET=utf8
```

#### 插入数据

```
INSERT INTO customers(cust_name,
						cust_address,
						cust_city,
						cust_state,
						cust_zip,
						cust_country,
						cust_contact,
						cust_email)
			VALUES('Pep E.lapew',
				'100 main street',
				'Los Angeles',
				'CA',
				'90046',
				'USA',
				NULL,
				NULL);
```

#### 更新和删除数据
```
#不要省略WHERE子句
UPDATE customers
SET cust_name = 'The fudd'
WHERE cust_id = 10005;

DELETE FROM　customers
WHERE cust_id = 10005;
```

#### 更新表
```
#给表添加一列
ALTER TABLE vendors
ADD vend_phone CHAR(20);
#删除刚刚添加的列
AlTER TABLE vendors
DROP COLUMN vend_phone;

#删除表
DROP TABLE customers2;
#重命名表
RENAME TABLE customers2 TO customers;
```
#### 选择数据库  
`SHOW DATABASES;`  
`USE DBNAME;`  
`SHOW TABLES;`  
`SHOW COLUMNS FROM DATABASES;`  OR `DESCRIBE DATABASES;`  
`SHOW CREATE DATABASES database_name`
`SHOW CREATE TABLE table_name`

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
#使用contact函数拼接字段，并使用别名,使用中文时要用""括起来
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
#### 使用数据处理函数
>Left() Right() Length() Lower() Upper() LTrim() 文本处理函数  

```
SELECT vend_name, UPPER(vend_name) as vend_name_upcase
FROM vendors
ORDER BY vend_name;
```
>CurDate() CurTime() Date() Datediff() Month() Now() Year() 时间处理函数  

````
#如果要的是日期，使用Date()
SELECT cust_id, order_num
FROM orders
WHERE Date(order_date) = '2005-09-01';
````  

#### 汇总数据
聚集函数（aggregate function）
> 聚合函数会将NULL排除在外，但COUNT()例外

- AVG()
- COUNT()
- MAX()
- MIN()
- SUM()

#### 分组数据
>除聚集计算语句外， select语句中每个列都必须在GROUP　BY子句中给出，GROUP BY子句中指定的列称为聚合键或分组键
```
SELECT vend_id, COUNT(*) AS num_prods
FROM products
GROUP BY vend_id;
```  

过滤分组使用HAVING子句
```
SELECT vend_id, COUNT(*) AS num_prods
FROM products
GROUP BY vend_id
HAVING COUNT(*) >= 3;
```

#### select子句顺序
1.SELECT  返回列或表达式
2.FROM  从中检索数据的表
3.WHERE　行级过滤
4.GROUP BY 分组说明
5.HAVING  组级过滤
6.ORDER BY 输出排序顺序
7.LIMIT 要检索的行数

#### select子句执行顺序
FROM -> WHERE -> GROUOP BY -> HAVING -> SELECT -> ORDER BY

#### 使用子查询
```
SELECT cust_id
FROM orders
WHERE order_num In (SELECT order_num
	                 FROM orderitems
				           WHERE prod_id = 'TNT2');
```
```
#作为计算字段使用子查询
SELECT cust_name, cust_state,(SELECT COUNT(*)
FROM orders
WHERE cust_id = cust_id) AS orders
FROM customers
ORDER BY cust_name;
```


#### 联结表
```
#应该保证所有联结都有WHERE子句
SELECT vend_name, prod_name, prod_price
FROM vendors, products
WHERE vendors.vend_id = products.vend_id
ORDER BY vend_name, prod_name;
#内部联结，结果相同
SELECT vend_name, prod_name, prod_price
FROM vendors INNER JOIN products
On vendors.vend_id = products.vend_id
ORDER BY vend_name, prod_name;
```
使用表别名
```
SELECT cust_name, cust_contact
FROM customers AS c, orders AS o, orderitems AS oi
WHERE c.cust_id = o.cust_id
AND oi.order_num = o.order_num
AND prod_id = 'TNT2';
```
自联结
```
SELECT p1.prod_id, p2.prod_name
FROM products AS p1, products AS p2
WHERE p1.vend_id = p2.vend_id
AND p2.prod_id = 'DTNTR';

#也可使用子查询
SELECT prod_id, prod_name
FROM products
WHERE vend_id = (SELECT vend_id
			FROM products
			WHERE prod_id = 'DTNTR');
```
外联结
```
#LEFT指出的是OUTER JOIN左边的表
SELECT customers.cust_id, orders.order_num
FROM customers LEFT OUTER JOIN orders
ON customers.cust_id = orders.cust_id;
```

#### 组合查询
```
#若要包含重复的行，可使用UNION ALL
SELECT vend_id, prod_id, prod_price
FROM products
WHERE prod_price <= 5
UNION
SELECT vend_id, prod_id, prod_price
FROM products
WHERE vend_id IN (1001,1002);
```

#### 使用视图
```
#查看创建视图的语句
SHOW CREATE VIEW viewname;
#删除视图
DROP VIEW viewname;

#例子
CREATE VIEW vendorlocations AS
SELECT CONCAT(rtrim(vend_name),RTRIM(vend_country)) AS vend_title
FROM vendors
ORDER BY vend_name;
#从视图查询
SELECT *
FROM vendorlocations;
```

#### 使用存储过程
```
#执行存储过程
CALL productpricing(@pricelow, @pricehigh, @priceaverage)

#创建存储过程
CREATE PROCEDURE productpricing()
BEGIN
	SELECT AVG(prod_price) AS priceaverage
	FROM products; #不要忘记;
END;

#使用参数
CREATE PROCEDURE productpricing(OUT pl DECIMAL(8,2), OUT ph DECIMAL(8,2), OUT pa DECIMAL(8,2))
BEGIN
	SELECT MIN(prod_price)
	INTO pl
	FROM products;
	SELECT MAX(prod_price)
	INTO ph
	FROM products;
	SELECT AVG(prod_price)
	INTO pa
	FROM products;
END;

#检查存储过程
SHOW CREATE PROCEDURE productpricing;

#删除存储过程
DROP PROCEDURE productpricing;
```

#### 使用游标
```
#创建游标
CREATE PROCEDURE processorders()
BEGIN
  DECLARE ordernumbers CURSOR
  FOR
  SELECT order_num FROM orders;
END;

#打开和关闭游标
OPEN ordernumbers;
CLOSE ordernumbers;
```

#### 使用触发器
```
#INSERT触发器
#引用一个NEW虚拟的表，访问被插入行，类比this指针
CREATE TRIGGER neworder AFTER INSERT ON orders
FOR EACH ROW SELECT NEW.order_num;

#DELETE触发器
#引用一个OLD虚拟的表，访问被删除行，只读，不能更改
CREATE TRIGGER deleteorder BEFORE DELETE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO archive_orders(order_num, order_date, cust_id)
    VALUES(OLD.order_num, OLD.order_date, OLD.cust_id);
END;

#UPDATE触发器
#BEFORE: NEW，AFTER: OLD
CREATE TRIGGER updatevendor BEFORE UPDATE ON vendors
FOR EACH ROW SET NEW.vend_state = Upper(NEW.vend_state);
```

#### 管理事务处理
```
#使用ROLLBACK
SELECT * FROM orderitems;
START TRANSACTION;
DELETE FROM orderitems;
SELECT * FROM orderitems;
ROLLBACK;
SELECT * FROM orderitems;

#使用COMMIT
START TRANSACTION;
DELETE FROM orderitems WHERE order_num = 20010;
DELETE FROM orders WHERE order_num = 20010;
COMMIT;

#使用SAVEPOINT
SAVEPOINT delete1;
ROLLBACK TO delete1;
```

#### 安全管理
```
#Mysql用户账号和信息存储在名为mysql的数据库中
use mysql;
SELECT user FROM user;

#创建用户账号
CREATE USER ben IDENTIFITED BY PASSWORD;
#重命名
RENAME USER ben TO bforta;

#删除用户账号
DROP USER bforta;

#设置用户权限
SHOW GRANTS FOR bforta;
GRANT SELECT ON crashcourse.* TO bforta;
REVOKE SELECT ON crashcourse.* FROM bforta；

#更改口令
SET PASSWORD FOR bforta = Password('new password');
```
