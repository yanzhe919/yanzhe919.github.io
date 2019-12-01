title: spring data jpa的一些使用笔记
date: 2016-03-19 23:23:52
tags: [Java,jpa,Oracle解锁]
categories: Java
description: 记录一些使用spring data jpa 中遇到的问题及解决。
---

JPA全称为Java持久性API（Java Persistence API），[Spring Data JPA](http://projects.spring.io/spring-data-jpa/)是Spring Data中的一种JPA实现。
示例可见[官方](http://spring.io/guides/gs/accessing-data-jpa/)，[文档](http://docs.spring.io/spring-data/data-jpa/docs/current/reference/html/)

## JPA使用Oracle序列作为实体ID


```java
@Entity
@Table(name="T_SPRINGJPA_USER")
public class User {
    /**
     * 主键序列：DEFAULT_SUQUENCE 是我在oracle数据库中创建的一个序列
     *           MY_SUQUENCE 是给自定义的序列随意创建一个引用名称
     * 指我的主键生成策略 MY_SUQUENCE 使用的是 DEFAULT_SUQUENCE 这个序列。
     */
    @SequenceGenerator(name = "MY_SUQUENCE", sequenceName = "DEFAULT_SUQUENCE")
    @Id
    @GeneratedValue(generator="MY_SUQUENCE")
    private Long id;

    @Column(name="USER_NAME")
    private String uName;
    
    //some get and set
}    
```

## 调用存储过程

```java 

//Referencing explicitly mapped procedure with name "plus1inout" in database.
@Procedure("plus1inout")
Integer explicitlyNamedPlus1inout(Integer arg);


//Referencing implicitly mapped procedure with name "plus1inout" in database via procedureName alias.
@Procedure(procedureName = "plus1inout")
Integer plus1inout(Integer arg);


//Referencing explicitly mapped named stored procedure "User.plus1IO" in EntityManager.
@Procedure(name = "User.plus1IO")
Integer entityAnnotatedCustomNamedProcedurePlus1IO(@Param("arg") Integer arg);


//Referencing implicitly mapped named stored procedure "User.plus1" in EntityManager via method-name.
@Procedure
Integer plus1(@Param("arg") Integer arg);



```

## JPA实现锁表

```java
//Defining lock metadata on query methods

interface UserRepository extends Repository<User, Long> {

  // Plain query method
  @Lock(LockModeType.READ)
  List<User> findByLastname(String lastname);
}



//Defining lock metadata on CRUD methods
interface UserRepository extends Repository<User, Long> {

  // Redeclaration of a CRUD method
  @Lock(LockModeType.READ);
  List<User> findAll();
}

```

行级锁
```java
import javax.persistence.LockModeType;  
import org.springframework.data.jpa.repository.JpaRepository;  
import org.springframework.data.jpa.repository.Lock;  
import org.springframework.data.jpa.repository.Query;  
import org.springframework.data.repository.query.Param;  
import org.springframework.stereotype.Repository;  
import com.xxx.xx.core.entity.UserInfo;  
@Repository  
public interface UserInfoDao extends JpaRepository<UserInfo, Long> {  
    @Query(value = "select j from UserInfo j where j.userName = :username ")  
    public UserInfo getUserForUpdate(@Param("username") String username);  
    @Lock(value = LockModeType.PESSIMISTIC_WRITE)  
    @Query(value = "select j from UserInfo j where j.id = :id ")  
    public void getUserByIdForUpdate(@Param("id") Long id);  
    @Lock(value = LockModeType.PESSIMISTIC_WRITE) // 会锁整个表
    @Query(value = "select j from UserInfo j where j.userName = :username ")  
    public void getUserByNameForUpdate(@Param("username") String username);  
}


import org.springframework.transaction.annotation.Transactional;  
  
public class UserService implements IUserService {  
    @Autowired  
    private UserInfoDao UserInfoDao;  
    @Transactional // 这个是需要标注的，因为Dao层有for update 的机制，那么这边就要开启事务了，否则会报错的。。。  
    public UserInfo getUserForUpdate(Long id) {  
        UserInfoDao.getUserByIdForUpdate(id);  
        try {  
            Thread.sleep(100000);  
        } catch (InterruptedException e) {  
        }  
        return null;  
    }  
}  
```

需要明确的指定主键，才会执行行级锁，否则执行的为表锁。
[MySQL中select * for update锁表的问题](http://blog.sina.com.cn/s/blog_88d2d8f501011sgl.html)

悲观所和乐观锁问题，这里的乐观锁比较简单，jpa有提供注解@Version，加上该注解，自动实现乐观锁，byId修改的时候sql自动变成：`update ... set ... where id = ? and version = ?`，比较方便。


在`Oracle`中，使用其他条件时，会在使用该数据集，如list时，锁表。形成多条锁表SQL语句。并不会直接表锁。

## Oracle锁表，解锁的一些描述

### 锁表

增删改查，封锁粒度都为行级。
事务锁（TX）
| 语句|类型|模式|
| -----|-------|------------|
|`Insert`|TX|排它（X）|
|`Update`|TX|排它（X）|
|`Delete`|TX|排它（X）|
|`Select`|TX|排它（X）|


通常的DML操作（SELECT…FOR UPDATE、INSERT、UPDATE、DELETE），在表级获得的只是意向锁（RS或RX），其真正的封锁粒度还是在行级；另外，Oracle数据库的一个显著特点是，在缺省情况下，单纯地读数据（SELECT）并不加锁，Oracle通过回滚段（Rollback segment）来保证用户不读"脏"数据。这些都提高了系统的并发程度。    
由于意向锁及数据行上锁标志位的引入，减小了Oracle维护行级锁的开销，这些技术的应用使Oracle能够高效地处理高度并发的事务请求。
锁表粒度[Oracle 数据封锁机制](http://www.oracle.com/technetwork/cn/community/developer-day/2-oracle-db-data-block-mechanism-2048769-zhs.pdf)

### 解锁

oracle 进程锁死 解锁
su - oracle

telnet 到服务器（用户；密码都是 oracle）运行下面的命令：
sqlplus system/manager as sysdba
再执行下面的Sql代码 
select sess.sid,sess.serial#,lo.oracle_username,lo.os_user_name,ao.object_name,lo.locked_mode from v$locked_object lo,dba_objects ao,v$session sess where ao.object_id = lo.object_id and lo.session_id = sess.sid;
杀掉锁表进程： 
如有記錄則表示有lock，記錄下SID 和 serial# ，將記錄的ID替換下面的738,1429，即可解除LOCK 
alter system kill session '738,1429'; 

select distinct t2.username, 
                'alter system kill session ''' || t2.sid || ',' || 
                t2.serial# || '''' || ';', 
                t3.object_name 被锁表名, 
                t4.spid 进程号, 
                t2.osuser os用户名, 
                t2.program 程序名 
  from v$locked_object t1 
inner join v$session t2 
    on t1.session_id = t2.sid 
inner join dba_objects t3 
    on t1.object_id = t3.object_id 
inner join v$process t4 
    on t2.paddr = t4.addr; 
    


## 常用JPA方法

### 查询

1、查询所有数据 `findAll()`

2、分页查询 `findAll(new PageRequest(0, 2))`     

3、根据id查询 `findOne()`      

4、根据实体类属性查询： `findByProperty (type Property);`   例如：`findByAge(int age);`

5、排序：  `findAll(sort )`
```java
      Sort sort = new Sort(Sort.Direction.DESC, "age").and (new Sort(Sort.Direction.DESC, "id"));
```
6、条件查询  `and/or/findByAgeLessThan/LessThanEqual` 等， 

     例如： `findByUsernameAndPassword(String username , String password)`

7、总数 查询 `count()`  或者 根据某个属性的值查询总数`countByAge(int age);`

8、是否存在某个id   `exists()`
### 修改，删除，新增

1. 新增：直接使用 `save(T)` 方法
2. 删除： `delete()`  或者  `deleteByProperty`   例如：`deleteByAge(int age)`  ;
3. 更新：  
```java
           @Modifying 
           @Query("update Customer u set u.age = ?1 where u.id = ?2")
           int update(int age1 , long id);
```

### 官网其他示例，方法名内支持的关键字

方法名内支持的关键字

| Keyword|Sample|JPQL snippet|
| -----|:-------:|------------|
|`And`|`findByLastnameAndFirstname`|`… where x.lastname = ?1 and x.firstname = ?2`|
|`Or`|`findByLastnameOrFirstname`|`… where x.lastname = ?1 or x.firstname = ?2`|
|`Is,Equals`|`findByFirstname,findByFirstnameIs,findByFirstnameEquals`|`… where x.firstname = 1?`|
|`Between`|`findByStartDateBetween`|`… where x.startDate between 1? and ?2`|
|`LessThan`|`findByAgeLessThan`|`… where x.age &lt; ?1`|
|`LessThanEqual`|`findByAgeLessThanEqual`|`… where x.age &#8656; ?1`|
|`GreaterThan`|`findByAgeGreaterThan`|`… where x.age &gt; ?1`|
|`GreaterThanEqual`|`findByAgeGreaterThanEqual`|`… where x.age &gt;= ?1`|
|`After`|`findByStartDateAfter`|`… where x.startDate &gt; ?1`|
|`Before`|`findByStartDateBefore`|`… where x.startDate &lt; ?1`|
|`IsNull`|`findByAgeIsNull`|`… where x.age is null`|
|`IsNotNull,NotNull`|`findByAge(Is)NotNull`|`… where x.age not null`|
|`Like`|`findByFirstnameLike`|`… where x.firstname like ?1`|
|`NotLike`|`findByFirstnameNotLike`|`… where x.firstname not like ?1`|
|`StartingWith`|`findByFirstnameStartingWith`|`… where x.firstname like ?1 (parameter bound with appended %)`|
|`EndingWith`|`findByFirstnameEndingWith`|`… where x.firstname like ?1 (parameter bound with prepended %)`|
|`Containing`|`findByFirstnameContaining`|`… where x.firstname like ?1 (parameter bound wrapped in %)`|
|`OrderBy`|`findByAgeOrderByLastnameDesc`|`… where x.age = ?1 order by x.lastname desc`|
|`Not`|`findByLastnameNot`|`… where x.lastname &lt;&gt; ?1`|
|`In`|`findByAgeIn(Collection&lt;Age&gt; ages)`|`… where x.age in ?1`|
|`NotIn`|`findByAgeNotIn(Collection&lt;Age&gt; age)`|`… where x.age not in ?1`|
|`True`|`findByActiveTrue()`|`… where x.active = true`|
|`False`|`findByActiveFalse()`|`… where x.active = false`|
|`IgnoreCase`|`findByFirstnameIgnoreCase`|`… where UPPER(x.firstame) = UPPER(?1)`|


