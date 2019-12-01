title: spring boot junit
date: 2016-05-04 12:15:31
tags: [Java,Spring,JUnit]
categories: Java
description: Spring boot 使用JUnit测试，可以导入测试相关包spring-boot-starter-test。
---

Spring boot 使用JUnit测试，可以导入测试相关包spring-boot-starter-test，pom文件中添加如下
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <!--  <version>${spring.boot.version}</version> -->
    <scope>test</scope>
</dependency>
```

## 使用JUnit


```java
@RunWith(SpringJUnit4ClassRunner.class) // SpringJUnit支持，由此引入Spring-Test框架支持！ 
@SpringApplicationConfiguration(classes = App.class) // 指定我们SpringBoot工程的Application启动类

//Web项目加如下注解
@WebAppConfiguration // 由于是Web项目，Junit需要模拟ServletContext，因此我们需要给我们的测试类加上@WebAppConfiguration。
```

### 基本JUnit注解


    1. @BeforeClass
    //在所有测试方法前执行一次，一般在其中写上整体初始化的代码 

    2. @AfterClass
    //在所有测试方法后执行一次，一般在其中写上销毁和释放资源的代码 

    3. @Before
    //在每个测试方法前执行，一般用来初始化方法（比如我们在测试别的方法时，类中与其他测试方法共享的值已经被改变，为了保证测试结果的有效性，我们会在@Before注解的方法中重置数据）

    4. @After
    //在每个测试方法后执行，在方法执行完成后要做的事情 

    5. @Test(timeout = 1000)
    // 测试方法执行超过1000毫秒后算超时，测试将失败 

    6. @Test(expected = Exception.class)
    // 测试方法期望得到的异常类，如果方法执行没有抛出指定的异常，则测试失败 

    7. @Ignore(“not ready yet”) 
       @Test
    // 执行测试时将忽略掉此方法，如果用于修饰类，则忽略整个类 

    8. @RunWith 
    在JUnit中有很多个Runner，他们负责调用你的测试代码，每一个Runner都有各自的特殊功能，你要根据需要选择不同的Runner来运行你的测试代码。 
    如果我们只是简单的做普通Java测试，不涉及Spring Web项目，你可以省略@RunWith注解，这样系统会自动使用默认Runner来运行你的代码。

### 参数化测试
    @RunWith(Parameterized.class)注解类，@Parameters注解方法。
```java
    @Parameters
    public static Collection<?> data(){
        // Object 数组中值的顺序注意要和上面的构造方法ParameterTest的参数对应
        return Arrays.asList(new Object[][]{
            {"小明2", true},
            {"坏", false},
            {"莉莉", false},
        });
    } 
```
### 套件测试
    @RunWith(Suite.class) 
    @SuiteClasses({ATest.class, BTest.class, CTest.class}) 

### 使用Junit测试HTTP的API接口

```java
@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(classes = SpringBootSampleApplication.class)
//@WebAppConfiguration // 使用@WebIntegrationTest注解需要将@WebAppConfiguration注释掉
@WebIntegrationTest("server.port:0")// 使用0表示端口号随机，也可以具体指定如8888这样的固定端口
public class HelloControllerTest {

    private String dateReg;
    private Pattern pattern;
    private RestTemplate template = new TestRestTemplate();
    @Value("${local.server.port}")// 注入端口号
    private int port;

    @Test
    public void test3(){
        String url = "http://localhost:"+port+"/myspringboot/hello/info";
        MultiValueMap<String, Object> map = new LinkedMultiValueMap<String, Object>(); 
        map.add("name", "Tom");  
        map.add("name1", "Lily");
        String result = template.postForObject(url, map, String.class);
        System.out.println(result);
        assertNotNull(result);
        assertThat(result, Matchers.containsString("Tom"));
    }

}

```

### 捕获输出

使用 OutputCapture 来捕获指定方法开始执行以后的所有输出，包括System.out输出和Log日志。 
OutputCapture 需要使用@Rule注解，并且实例化的对象需要使用public修饰，如下代码：
```java
@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(classes = SpringBootSampleApplication.class)
//@WebAppConfiguration // 使用@WebIntegrationTest注解需要将@WebAppConfiguration注释掉
@WebIntegrationTest("server.port:0")// 使用0表示端口号随机，也可以具体指定如8888这样的固定端口
public class HelloControllerTest {

    @Value("${local.server.port}")// 注入端口号
    private int port;

    private static final Logger logger = LoggerFactory.getLogger(StudentController.class);

    @Rule
    // 这里注意，使用@Rule注解必须要用public
    public OutputCapture capture = new OutputCapture();

    @Test
    public void test4(){
        System.out.println("HelloWorld");
        logger.info("logo日志也会被capture捕获测试输出");
        assertThat(capture.toString(), Matchers.containsString("World"));
    }
}
```

更加详细的Spring Boot Junit单元测试，可以参考[这篇博文](http://blog.csdn.net/catoop/article/details/50752964)
