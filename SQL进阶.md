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

## 外连接的用法

#### 作为乘法运算的连接
```
/* 解答（1）：通过在连接前聚合来创建一对一的关系 */
SELECT I.items_no, SH.total_qty
FROM items I LEFT OUTER JOIN
  (SELECT item_no, SUM(quantity) AS total_qty
    FROM SalesHistory
    GROUP BY item_no) SH
  ON I.item_no = SH.item_no;
```
```
/* 解答(2)：先进行一对多的连接再聚合 */
SELECT I.item_no, SUM(SH.quantity) AS total_qty
  FROM Items I LEFT OUTER JOIN SalesHistory SH
    ON I.item_no = SH.item_no /* 一对多的连接 */
 GROUP BY I.item_no;
```
>一对一或一对多关系的两个集合，在连接后行数不会增加，结果不变

#### 全外连接

- LEFT OUT JOIN 左外连接
- RIGHT OUT JOIN 右外连接
- FULL OUT JOIN 全外连接

```
/* 全外连接保留全部信息 */
SELECT COALESCE(A.id, B.id) AS id,
       A.name AS A_name,
       B.name AS B_name
FROM Class_A  A  FULL OUTER JOIN Class_B  B
  ON A.id = B.id;
```

>内连接相当于求集合的积（intersect，交集）， 全外连接相当于求集合的和（union，并集）

#### 用外连接进行集合运算

```
/* 用外连接求差集：A－B */
SELECT A.id AS id,  A.name AS A_name
  FROM Class_A  A LEFT OUTER JOIN Class_B B
    ON A.id = B.id
 WHERE B.name IS NULL;
```
```
/* 用外连接求差集：B－A */
SELECT B.id AS id, B.name AS B_name
  FROM Class_A  A  RIGHT OUTER JOIN Class_B B
    ON A.id = B.id
 WHERE A.name IS NULL;
```
```
/* 用全外连接求异或集 */
SELECT COALESCE(A.id, B.id) AS id,
       COALESCE(A.name , B.name ) AS name
  FROM Class_A  A  FULL OUTER JOIN Class_B  B
    ON A.id = B.id
 WHERE A.name IS NULL
    OR B.name IS NULL;
```
```
/* 用外连接进行关系除法运算：差集的应用 */
SELECT DISTINCT shop
  FROM ShopItems SI1
WHERE NOT EXISTS
      (SELECT I.item
         FROM Items I LEFT OUTER JOIN ShopItems SI2
           ON SI1.shop = SI2.shop
          AND I.item   = SI2.item
        WHERE SI2.item IS NULL) ;
```

### 用关联子查询比较行与行

#### 增加，减少，维持现状
```
/* 求与上一年营业额一样的年份（1）：使用关联子查询 */
SELECT year,sale
  FROM Sales S1
 WHERE sale = (SELECT sale
                 FROM Sales S2
                WHERE S2.year = S1.year - 1)
 ORDER BY year;

 /* 求与上一年营业额一样的年份（2）：使用自连接 */
 SELECT S1.year, S1.sale
   FROM Sales S1,
        Sales S2
  WHERE S2.sale = S1.sale
    AND S2.year = S1.year - 1
  ORDER BY year;
```

#### 用列表展示比较结果
```
/* 求出是增长了还是减少了，抑或是维持现状（1）：使用关联子查询 */
SELECT S1.year, S1.sale,
       CASE WHEN sale =
             (SELECT sale
                FROM Sales S2
               WHERE S2.year = S1.year - 1) THEN '→' /* 持平 */
            WHEN sale >
             (SELECT sale
                FROM Sales S2
               WHERE S2.year = S1.year - 1) THEN '↑' /* 增长 */
            WHEN sale <
             (SELECT sale
                FROM Sales S2
               WHERE S2.year = S1.year - 1) THEN '↓' /* 减少 */
       ELSE '—' END AS var
  FROM Sales S1
 ORDER BY year;

 /* 求出是增长了还是减少了，抑或是维持现状（2）：使用自连接查询 */
 SELECT S1.year, S1.sale,
        CASE WHEN S1.sale = S2.sale THEN '→'
             WHEN S1.sale > S2.sale THEN '↑'
             WHEN S1.sale < S2.sale THEN '↓'
        ELSE '—' END AS var
   FROM Sales S1, Sales S2
  WHERE S2.year = S1.year-1
  ORDER BY year;
```

#### 时间轴有间断时
```
/* 查询与过去最临近的年份营业额相同的年份 */
SELECT year, sale
  FROM Sales2 S1
 WHERE sale =
   (SELECT sale
      FROM Sales2 S2
     WHERE S2.year =
       (SELECT MAX(year)            /* 条件2：在满足条件1的年份中，年份最早的一个 */
          FROM Sales2 S3
         WHERE S1.year > S3.year))  /* 条件1：与该年份相比是过去的年份 */
 ORDER BY year;

 /* 查询与过去最临近的年份营业额相同的年份：同时使用自连接 */
 SELECT S1.year AS year,
        S1.sale AS sale
   FROM Sales2 S1, Sales2 S2
  WHERE S1.sale = S2.sale
    AND S2.year = (SELECT MAX(year)
                     FROM Sales2 S3
                    WHERE S1.year > S3.year)
  ORDER BY year;
```

```
/* 求每一年与过去最临近的年份之间的营业额之差（1）：结果里不包含最早的年份 */
SELECT S2.year AS pre_year,
       S1.year AS now_year,
       S2.sale AS pre_sale,
       S1.sale AS now_sale,
       S1.sale - S2.sale  AS diff
 FROM Sales2 S1, Sales2 S2
 WHERE S2.year = (SELECT MAX(year)
                    FROM Sales2 S3
                   WHERE S1.year > S3.year)
 ORDER BY now_year;

 /* 求每一年与过去最临近的年份之间的营业额之差（2）：使用自外连接。结果里包含最早的年份 */
 SELECT S2.year AS pre_year,
        S1.year AS now_year,
        S2.sale AS pre_sale,
        S1.sale AS now_sale,
        S1.sale - S2.sale AS diff
  FROM Sales2 S1 LEFT OUTER JOIN Sales2 S2
    ON S2.year = (SELECT MAX(year)
                    FROM Sales2 S3
                   WHERE S1.year > S3.year)
  ORDER BY now_year;
 ```

#### 移动累计值和移动平均值

```
/* 求累计值：使用窗口函数 */
SELECT prc_date, prc_amt,
       SUM(prc_amt) OVER (ORDER BY prc_date) AS onhand_amt
  FROM Accounts;

  /* 求累计值：使用冯·诺依曼型递归集合 */
  SELECT prc_date, A1.prc_amt,
        (SELECT SUM(prc_amt)
           FROM Accounts A2
          WHERE A1.prc_date >= A2.prc_date ) AS onhand_amt
    FROM Accounts A1
   ORDER BY prc_date;
```
```
/* 求移动累计值（1）：使用窗口函数 */
SELECT prc_date, prc_amt,
       SUM(prc_amt) OVER (ORDER BY prc_date
                           ROWS 2 PRECEDING) AS onhand_amt
  FROM Accounts;

/* 求移动累计值（2）：不满3行的时间区间也输出 */
  SELECT prc_date, A1.prc_amt,
        (SELECT SUM(prc_amt)
           FROM Accounts A2
          WHERE A1.prc_date >= A2.prc_date
            AND (SELECT COUNT(*)
                   FROM Accounts A3
                  WHERE A3.prc_date
                    BETWEEN A2.prc_date AND A1.prc_date  ) <= 3 ) AS mvg_sum
    FROM Accounts A1
   ORDER BY prc_date;
```

```
/* 求重叠的住宿期间 */
SELECT reserver, start_date, end_date
  FROM Reservations R1
 WHERE EXISTS
       (SELECT *
          FROM Reservations R2
         WHERE R1.reserver <> R2.reserver  /* 与自己以外的客人进行比较 */
           AND ( R1.start_date BETWEEN R2.start_date AND R2.end_date    /* 条件（1）：自己的入住日期在他人的住宿期间内 */
              OR R1.end_date  BETWEEN R2.start_date AND R2.end_date));  /* 条件（2）：自己的离店日期在他人的住宿期间
```

### 用SQL进行集合运算

- SQL能操作具有重复行的集合，通过ALL选项来支持
- 集合运算符有优先级， INTERSECT在UNION和EXCEPT前
- 除法运算没有标准定义

#### 检查集合相等性
```
/* 比较表和表：基础篇 */
SELECT COUNT(*) AS row_cnt
  FROM ( SELECT *
           FROM tbl_A
         UNION
         SELECT *
           FROM tbl_B ) TMP;
```
>如果两个集合相等，则它们的并集也是相等的。——幂等性
>union具有幂等性，union all不具有幂等性

```
/* 比较表和表：进阶篇（在Oracle中无法运行） */
SELECT DISTINCT CASE WHEN COUNT(*) = 0
                     THEN '相等'
                     ELSE '不相等' END AS result
  FROM ((SELECT * FROM  tbl_A
         UNION
         SELECT * FROM  tbl_B)
         EXCEPT
        (SELECT * FROM  tbl_A
         INTERSECT
         SELECT * FROM  tbl_B)) TMP;
```
>如果两个集合相等，则 A UNION B = A = B,A INTERSECT B = A =B,(A UNION B) EXCEPT (A INTERSECT B) 为空集

#### 用差集实现关系除法运算
- 嵌套使用NOT EXISTS
- 使用HAVING子句转换为一对一关系
- 把除法变成乘法

```
/* 用求差集的方法进行关系除法运算（有余数） */
SELECT DISTINCT emp
  FROM EmpSkills ES1
 WHERE NOT EXISTS
        (SELECT skill
           FROM Skills
         EXCEPT
         SELECT skill
           FROM EmpSkills ES2
          WHERE ES1.emp = ES2.emp);
```

#### 寻找相同的子集
```
/* 寻找相等的子集 */
SELECT SP1.sup, SP2.sup
  FROM SupParts SP1, SupParts SP2
 WHERE SP1.sup < SP2.sup              /* 生成供应商的全部组合 */
   AND SP1.part = SP2.part            /* 条件1：经营同种类型的零件 */
GROUP BY SP1.sup, SP2.sup
HAVING COUNT(*) = (SELECT COUNT(*)    /* 条件2：经营的零件种类数相同 */
                     FROM SupParts SP3
                    WHERE SP3.sup = SP1.sup)
   AND COUNT(*) = (SELECT COUNT(*)
                     FROM SupParts SP4
                    WHERE SP4.sup = SP2.sup);
```

#### 用于删除重复行的高效SQL
```
-- 删除重复行：使用关联子查询
DELETE FROM Products
 WHERE rowid < (SELECT MAX(p2.rowid)
                FROM Products p2
                WHERE Products.name = p2.name
                AND Products.price = p2.price);
```
```
/* 用于删除重复行的高效SQL语句（1）：通过EXCEPT求补集 */
DELETE FROM Products
 WHERE rowid IN ( SELECT rowid
                    FROM Products   --全部rowid
                  EXCEPT            --减去
                  SELECT MAX(rowid) --要留下的rowid
                    FROM Products
                   GROUP BY name, price);

/* 删除重复行的高效SQL语句（2）：通过NOT IN求补集 */
DELETE FROM Products
 WHERE rowid NOT IN ( SELECT MAX(rowid)
                        FROM Products
                       GROUP BY name, price);

```

### EXISTS谓词的用法

>用一句话来说，谓词就是函数。不过是一种特殊的函数，返回的值是真值，即true，false和unknow。

#### 查询表中“不”存在的数据
```
/* 用于求出缺席者的SQL语句（1）：存在量化的应用 */
SELECT DISTINCT M1.meeting, M2.person
  FROM Meetings M1 CROSS JOIN Meetings M2
 WHERE NOT EXISTS
        (SELECT *
           FROM Meetings M3
          WHERE M1.meeting = M3.meeting
            AND M2.person = M3.person);

/* 用于求出缺席者的SQL语句（2）：使用差集运算 */
SELECT M1.meeting, M2.person
  FROM Meetings M1, Meetings M2
EXCEPT
SELECT meeting, person
  FROM Meetings;
```
>NOT EXISTS具备了差集运算的功能

#### “肯定”和“双重否定”之间的转换

```
/* 全称量化（1）：习惯“肯定<＝>双重否定”之间的转换 */
SELECT DISTINCT student_id
  FROM TestScores TS1
 WHERE NOT EXISTS  /* 不存在满足以下条件的行 */
        (SELECT *
           FROM TestScores TS2
          WHERE TS2.student_id = TS1.student_id
            AND TS2.score < 50);   /* 分数不满50分的科目 */

/* 全称量化（1）：习惯“肯定<＝>双重否定”之间的转换 */
SELECT student_id
  FROM TestScores TS1
 WHERE subject IN ('数学', '语文')
   AND NOT EXISTS
        (SELECT *
           FROM TestScores TS2
          WHERE TS2.student_id = TS1.student_id
            AND 1 = CASE WHEN subject = '数学' AND score < 80 THEN 1
                         WHEN subject = '语文' AND score < 50 THEN 1
                         ELSE 0 END)
 GROUP BY student_id
HAVING COUNT(*) = 2; /* 必须两门科目都有分数 */
```

#### 查询全是1的行
```
/* “列方向”的全称量化：不优雅的解答 */
SELECT *
  FROM ArrayTbl
 WHERE col1 = 1
   AND col2 = 1
   AND col3 = 1
   AND col4 = 1
   AND col5 = 1
   AND col6 = 1
   AND col7 = 1
   AND col8 = 1
   AND col9 = 1
   AND col10 = 1;

/* “列方向”的全称量化：优雅的解答 */
SELECT *
  FROM ArrayTbl
 WHERE 1 = ALL (col1, col2, col3, col4, col5, col6, col7, col8, col9, col10);
```

```
/* “列方向”的存在量化（1） */
SELECT *
  FROM ArrayTbl
 WHERE 9 = ANY (col1, col2, col3, col4, col5, col6, col7, col8, col9, col10);

 /* “列方向”的存在量化（2） */
 SELECT *
   FROM ArrayTbl
  WHERE 9 IN (col1, col2, col3, col4, col5, col6, col7, col8, col9, col10);

```
```
/* 查询全是NULL的行：错误的解法 */
SELECT *
  FROM ArrayTbl
 WHERE NULL = ALL (col1, col2, col3, col4, col5, col6, col7, col8, col9, col10);

/* 查询全是NULL的行：正确的解法 */
SELECT *
  FROM ArrayTbl
 WHERE COALESCE(col1, col2, col3, col4, col5, col6, col7, col8, col9, col10) IS NULL;
 ```

### 用SQL处理数列

#### 生成连续编号
```
/* 求连续编号（1）：求0到99的数 */
SELECT D1.digit + (D2.digit * 10)  AS seq
  FROM Digits D1, Digits D2
ORDER BY seq;

/* 求连续编号（2）：求1到520的数 */
SELECT D1.digit + (D2.digit * 10) + (D3.digit * 100) AS seq
  FROM Digits D1, Digits D2, Digits D3
 WHERE D1.digit + (D2.digit * 10) + (D3.digit * 100) BETWEEN 1 AND 520
ORDER BY seq;
```

```
/* 生成序列视图（包含0到999） */
CREATE VIEW Sequence (seq)
AS SELECT D1.digit + (D2.digit * 10) + (D3.digit * 100)
     FROM Digits D1, Digits D2, Digits

/* 从序列视图中获取1到100 */
SELECT seq
  FROM Sequence
 WHERE seq BETWEEN 1 AND 100
ORDER BY seq;
```

#### 求全部的缺失编号
```
/* 求所有缺失编号：EXCEPT版 */
SELECT seq
  FROM Sequence
 WHERE seq BETWEEN 1 AND 12
EXCEPT
SELECT seq FROM SeqTbl;

/* 求所有缺失编号：NOT IN版 */
SELECT seq
  FROM Sequence
 WHERE seq BETWEEN 1 AND 12
   AND seq NOT IN (SELECT seq FROM SeqTbl);

/* 动态地指定连续编号范围的SQL语句 */
SELECT seq
  FROM Sequence
 WHERE seq BETWEEN (SELECT MIN(seq) FROM SeqTbl)
               AND (SELECT MAX(seq) FROM SeqTbl)
EXCEPT
SELECT seq FROM SeqTbl;
```

#### 最多能坐多少人
```
/* 找出需要的空位（1）：不考虑座位的换排 */
SELECT S1.seat   AS start_seat, '～' , S2.seat AS end_seat
  FROM Seats S1, Seats S2
 WHERE S2.seat = S1.seat + (:head_cnt -1)  /* 决定起点和终点 */
   AND NOT EXISTS
          (SELECT *
             FROM Seats S3
            WHERE S3.seat BETWEEN S1.seat AND S2.seat
              AND S3.status <> '未预订' )
ORDER BY start_seat;

/* 找出需要的空位（2）：考虑座位的换排 */
SELECT S1.seat   AS start_seat, '～' , S2.seat AS end_seat
  FROM Seats2 S1, Seats2 S2
 WHERE S2.seat = S1.seat + (:head_cnt -1)  --决定起点和终点
   AND NOT EXISTS
          (SELECT *
             FROM Seats2 S3
            WHERE S3.seat BETWEEN S1.seat AND S2.seat
              AND (    S3.status <> '未预订'
                    OR S3.row_id <> S1.row_id))
ORDER BY start_seat;
```
```
/* 第一阶段：生成存储了所有序列的视图 */
CREATE VIEW Sequences (start_seat, end_seat, seat_cnt) AS
SELECT S1.seat  AS start_seat,
       S2.seat  AS end_seat,
       S2.seat - S1.seat + 1 AS seat_cnt
  FROM Seats3 S1, Seats3 S2
 WHERE S1.seat <= S2.seat  /* 第一步：生成起点和终点的组合 */
   AND NOT EXISTS   /* 第二步：描述序列内所有点需要满足的条件 */
       (SELECT *
          FROM Seats3 S3
         WHERE (     S3.seat BETWEEN S1.seat AND S2.seat
                 AND S3.status <> '未预订')                         /* 条件1的否定 */
            OR  (S3.seat = S2.seat + 1 AND S3.status = '未预订' )    /* 条件2的否定 */
            OR  (S3.seat = S1.seat - 1 AND S3.status = '未预订' ));  /* 条件3的否定 */


/* 第二阶段：求最长的序列 */
SELECT start_seat, '～', end_seat, seat_cnt
  FROM Sequences
 WHERE seat_cnt = (SELECT MAX(seat_cnt) FROM Sequences);
```

### HAVING子句再谈

#### 查询可以出勤的队伍

```
/* 用谓词表达全称量化命题 */
SELECT team_id, member
  FROM Teams T1
 WHERE NOT EXISTS
        (SELECT *
           FROM Teams T2
          WHERE T1.team_id = T2.team_id
            AND status <> '待命' );
```
```
/* 用集合表达全称量化命题（1） */
SELECT team_id
  FROM Teams
 GROUP BY team_id
HAVING COUNT(*) = SUM(CASE WHEN status = '待命'
                           THEN 1
                           ELSE 0 END);

/* 用集合表达全称量化命题（2） */
SELECT team_id
  FROM Teams
 GROUP BY team_id
HAVING MAX(status) = '待命'
   AND MIN(status) = '待命';                         
```
>集合中最大值等于最小值，则这个集合只有一个值

#### 单重集合和多重集合

```
/* 选中材料存在重复的生产地 */
SELECT center
  FROM Materials
 GROUP BY center
HAVING COUNT(material) <> COUNT(DISTINCT material);

/* 列表显示是否存在重复 */
SELECT center,
       CASE WHEN COUNT(material) <> COUNT(DISTINCT material)
            THEN '存在重复'
            ELSE '不存在重复' END AS status
  FROM Materials
 GROUP BY center;
```
```
/* 存在重复的集合：使用EXISTS */
SELECT center, material
  FROM Materials M1
 WHERE EXISTS
       (SELECT *
          FROM Materials M2
         WHERE M1.center = M2.center
           AND M1.receive_date <> M2.receive_date
           AND M1.material = M2.material);
```

#### 寻找缺失的编号：升级版
```
--前提条件：数列起始值为1
SELECT '存在缺失的编号' AS gap
FROM SeqTbl
HAVING COUNT(*) <> MAX(seq);

/* 如果有查询结果，说明存在缺失的编号：只调查数列的连续性 */
SELECT '存在缺失的编号' AS gap
  FROM SeqTbl
HAVING COUNT(*) <> MAX(seq) - MIN(seq) + 1;
```
```
/* 查找最小的缺失编号：表中没有1时返回1 */
SELECT CASE WHEN MIN(seq) > 1          /* 最小值不是1时→返回1 */
            THEN 1
            ELSE (SELECT MIN(seq +1)  /* 最小值是1时→返回最小的缺失编号 */
                    FROM SeqTbl S1
                   WHERE NOT EXISTS
                        (SELECT *
                           FROM SeqTbl S2
                          WHERE S2.seq = S1.seq + 1))
             END AS min_gap
  FROM SeqTbl;
```

#### 为集合设置详细的条件

```
/* 75%以上的学生分数都在80分以上的班级 */
SELECT class
  FROM TestResults
GROUP BY class
HAVING COUNT(*) * 0.75
         <= SUM(CASE WHEN score >= 80
                     THEN 1
                     ELSE 0 END) ;
```
```
/* 分数在50分以上的男生的人数比分数在50分以上的女生的人数多的班级 */
SELECT class
  FROM TestResults
GROUP BY class
HAVING SUM(CASE WHEN score >= 50 AND sex = '男'
                THEN 1
                ELSE 0 END)
       > SUM(CASE WHEN score >= 50 AND sex = '女'
                  THEN 1
                  ELSE 0 END) ;
```
```
/* 分数在50分以上的男生的人数比分数在50分以上的女生的人数多的班级 */
SELECT class
  FROM TestResults
GROUP BY class
HAVING SUM(CASE WHEN score >= 50 AND sex = '男'
                THEN 1
                ELSE 0 END)
       > SUM(CASE WHEN score >= 50 AND sex = '女'
                  THEN 1
                  ELSE 0 END) ;

/* 比较男生和女生平均分的SQL语句（2）：对空集求平均值后返回NULL */
SELECT class
  FROM TestResults
 GROUP BY class
HAVING AVG(CASE WHEN sex = '男'
                THEN score
                ELSE NULL END)
     < AVG(CASE WHEN sex = '女'
                THEN score
                ELSE NULL END);
```
