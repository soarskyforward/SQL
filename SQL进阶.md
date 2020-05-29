# SQL
 >进阶技巧


### CASE表达式
>CASE表达式表达式有简单case表达式和搜索case表达式两种写法

#### case表达式概述

```
--简单case表达式
CASE sex
WHEN '1' THEN 'male'
WHEN '2' THEN 'female'
ELSE 'other' END

--搜索case表达式
CASE
WHEN sex = 1 THEN 'male'
WHEN sex = 2 THEN 'female'
ELSE 'other' END
```

- 统一各分支返回的数据类型
- 不要忘记写END
- 养成写ELSE的习惯

#### 将已有编号方式转换为新的方式并统计
```
--关键在于将SELECT子句中的CASE表达式复制到GROUP BY子句里
SELECT CASE pref_name
             WHEN '德岛' THEN '四国'
             WHEN '香川' THEN '四国'
             WHEN '爱媛' THEN '四国'
             WHEN '高知' THEN '四国'
             WHEN '福冈' THEN '九州'
             WHEN '佐贺' THEN '九州'
             WHEN '长崎' THEN '九州'
             ELSE '其他' END AS district,
       SUM(population)
  FROM PopTbl
 GROUP BY CASE pref_name
             WHEN '德岛' THEN '四国'
             WHEN '香川' THEN '四国'
             WHEN '爱媛' THEN '四国'
             WHEN '高知' THEN '四国'
             WHEN '福冈' THEN '九州'
             WHEN '佐贺' THEN '九州'
             WHEN '长崎' THEN '九州'
             ELSE '其他' END;
```

#### 用一条语句进行不同条件的统计
```
--使用union语句
SELECT pref_name,SUM(population)
FROM PopTbl2
WHERE sex = '1'
GROUP BY pref_name
UNION
SELECT pref_name,SUM(population)
FROM PopTbl2
WHERE sex = '2'
GROUP BY pref_name;

--使用case语句优化
SELECT pref_name,
       /* 男性人口 */
       SUM( CASE WHEN sex = '1' THEN population ELSE 0 END) AS cnt_m,
       /* 女性人口 */
       SUM( CASE WHEN sex = '2' THEN population ELSE 0 END) AS cnt_f
  FROM PopTbl2
 GROUP BY pref_name;
```

#### 在update语句中进行条件分支
```
/* 用CASE表达式写正确的更新操作 */
UPDATE Salaries
   SET salary = CASE WHEN salary >= 300000
                     THEN salary * 0.9
                     WHEN salary >= 250000 AND salary < 280000
                     THEN salary * 1.2
                     ELSE salary END;
```
```
/* 用CASE表达式调换主键值 */
UPDATE SomeTable
   SET p_key = CASE WHEN p_key = 'a'
                    THEN 'b'
                    WHEN p_key = 'b'
                    THEN 'a'
                    ELSE p_key END
 WHERE p_key IN ('a', 'b');
```

#### 表之间的数据匹配
```
/* 表的匹配：使用EXISTS谓词 */
SELECT CM.course_name,
       CASE WHEN EXISTS
                    (SELECT course_id FROM OpenCourses OC
                      WHERE month = 200706
                        AND CM.course_id = OC.course_id) THEN '○'
            ELSE '×' END AS "6月",
       CASE WHEN EXISTS
                    (SELECT course_id FROM OpenCourses OC
                      WHERE month = 200707
                        AND CM.course_id = OC.course_id) THEN '○'
            ELSE '×' END AS "7月",
       CASE WHEN EXISTS
                    (SELECT course_id FROM OpenCourses OC
                      WHERE month = 200708
                        AND CM.course_id = OC.course_id) THEN '○'
            ELSE '×' END  AS "8月"
  FROM CourseMaster CM;
```

### 自连接的用法
>针对相同的表进行的连接被称为“自连接”

#### 可重排序，排列，组合
```
/* 用于获取可重排列的SQL语句 */
SELECT P1.name AS name_1, P2.name AS name_2
  FROM Products P1, Products P2;

/* 用于获取排列的SQL语句 */
SELECT P1.name AS name_1, P2.name AS name_2
  FROM Products P1, Products P2
  WHERE P1.name <> P2.name;

/* 用于获取组合的SQL语句 */
SELECT P1.name AS name_1, P2.name AS name_2
  FROM Products P1, Products P2
  WHERE P1.name > P2.name;
```
>"<，>， <>"进行的连接称为非等值自连接。在获取列的组合时经常用到

#### 删除重复行
```
/* 用于删除重复行的SQL语句（2）：使用非等值连接 */
DELETE FROM Products P1
 WHERE EXISTS ( SELECT *
                  FROM Products P2
                 WHERE P1.name = P2.name
                   AND P1.price = P2.price
                   AND P1.rowid < P2.rowid );
```
>无论是表还是试图，本质上都是集合——集合是SQL唯一能处理的数据结构

#### 查找局部不一致的列
```
/* 用于查找价格相等但商品名称不同的记录的SQL语句 */
SELECT DISTINCT P1.name, P1.price
  FROM Products P1, Products P2
 WHERE P1.price = P2.price
   AND P1.name <> P2.name;
```

#### 排序
```
/* 排序：使用窗口函数 */
SELECT name, price,
       RANK() OVER (ORDER BY price DESC) AS rank_1,
       DENSE_RANK() OVER (ORDER BY price DESC) AS rank_2
  FROM Products;

/* 排序从1开始。如果已出现相同位次，则跳过之后的位次 */
  SELECT P1.name,
         P1.price,
        (SELECT COUNT(P2.price)
           FROM Products P2
          WHERE P2.price > P1.price) + 1 AS rank_1
   FROM Products P1
   ORDER BY rank_1;
```
>修改为count(distinct p2.price)则相当于dense_rank()

### 三值逻辑和NULL

AND的情况：false > unknow > true
OR的情况：true > unknow > false

```
/* 添加第3个条件：年龄是20岁，或者不是20岁，或者年龄未知 */
SELECT *
  FROM Students
 WHERE age = 20
    OR age <> 20
    OR age IS NULL;
```

NOT IN 和 NOT EXISTS不是等价的
```
/* 查询与B班住在东京的学生年龄不同的A班学生的SQL语句？ */
SELECT *
  FROM Class_A
 WHERE age NOT IN ( SELECT age
                      FROM Class_B
                     WHERE city = '东京' );
```
>如果NOT IN子查询中用到的表里被选中的列中有NULL，这查询结果永远是空
```
/* 正确的SQL语句：拉里和伯杰将被查询到 */
SELECT *
  FROM Class_A A
 WHERE NOT EXISTS ( SELECT *
                      FROM Class_B B
                     WHERE A.age = B.age
                       AND B.city = '东京' );
```
>EXISTS谓词只会返回true和false，永远不会返回unknow

>in和exists可以互用，但not in和not exists不能互用

- null不是值
- 因为null不是值，所以不能对其使用谓语
- 使用谓语的后果是返回unknow

### HAVING子句的力量

#### 寻找缺失的编号
```
/* 如果有查询结果，说明存在缺失的编号 */
SELECT '存在缺失的编号' AS gap
  FROM SeqTbl
HAVING COUNT(*) <> MAX(seq);
--WHERE子句中不能出现聚合函数
```
>having子句是可以单独使用的

```
/* 查询缺失编号的最小值 */
SELECT MIN(seq + 1) AS gap
FROM SeqTbl
WHERE (seq + 1) NOT IN (SELECT seq FROM SeqTbl)
```

#### 使用HAVING子句进行子查询：求众数
```
/* 求众数的SQL语句（1）：使用谓词 */
  SELECT income, COUNT(*) AS cnt
    FROM Graduates
   GROUP BY income
  HAVING COUNT(*) >= ALL ( SELECT COUNT(*)
                             FROM Graduates
                         GROUP BY income);
```
```
/* 求众数的SQL语句(2)：使用极值函数 */
SELECT income, COUNT(*) AS cnt
  FROM Graduates
 GROUP BY income
HAVING COUNT(*) >=  ( SELECT MAX(cnt)
                        FROM ( SELECT COUNT(*) AS cnt
                                 FROM Graduates
                             GROUP BY income) TMP) ;
```

#### 使用HAVING子句进行子查询：求中位数
```
/* 求中位数的SQL语句：在HAVING子句中使用非等值自连接 */
SELECT AVG(DISTINCT income)
  FROM (SELECT T1.income
          FROM Graduates T1, Graduates T2
      GROUP BY T1.income
               /* S1的条件 */
        HAVING SUM(CASE WHEN T2.income >= T1.income THEN 1 ELSE 0 END)
                   >= COUNT(*) / 2
               /* S2的条件 */
           AND SUM(CASE WHEN T2.income <= T1.income THEN 1 ELSE 0 END)
                   >= COUNT(*) / 2 ) TMP;
```

#### 查询不含NULL的集合
```
/* 查询“提交日期”列内不包含NULL的学院(1)：使用COUNT函数 */
SELECT dpt
  FROM Students
 GROUP BY dpt
HAVING COUNT(*) = COUNT(sbmt_date);

/* 查询“提交日期”列内不包含NULL的学院(2)：使用CASE表达式 */
SELECT dpt
  FROM Students
 GROUP BY dpt
HAVING COUNT(*) = SUM(CASE WHEN sbmt_date IS NOT NULL
                           THEN 1
                           ELSE 0 END);
```

#### 用关系除法运算进行购物篮分析
```
/* 查询啤酒、纸尿裤和自行车同时在库的店铺：正确的SQL语句 */
SELECT SI.shop
FROM ShopItems SI, Items I
WHERE SI.item = I.Item
GROUP BY SI.shop
HAVING COUNT(SI.item) = (SELECT COUNT(item) FROM Items);

/* 精确关系除法运算：使用外连接和COUNT函数 */
  SELECT SI.shop
    FROM ShopItems AS SI LEFT OUTER JOIN Items AS I
      ON SI.item=I.item
GROUP BY SI.shop
  HAVING COUNT(SI.item) = (SELECT COUNT(item) FROM Items)   /* 条件1 */
     AND COUNT(I.item)  = (SELECT COUNT(item) FROM Items);  /* 条件2 */
```
