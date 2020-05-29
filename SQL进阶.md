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
