title: 关于使用Spring Boot的一些记录
date: 2016-03-24 11:12:22
tags: [Java,Spring boot]
categories: Java
description: 
---

[Spring Boot](http://projects.spring.io/spring-boot/)，可以使人轻松的创建一个Spring工程，"just run"。[官方示例](http://spring.io/guides/gs/spring-boot/)。[官方文档](http://docs.spring.io/spring-boot/docs/current-SNAPSHOT/reference/htmlsingle/)。一个不错的[中文文档](https://github.com/qibaoguang/Spring-Boot-Reference-Guide/blob/master/all%20in%20one/spring_boot_features.md)

Spring Boot 最少需要java6，java7最好，官方推荐java8
可以指定为java6

<!-- more -->

```xml
 <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <!-- 这里一定要配置上java的版本，如果是1.7版本的可不用配置 -->
        <java.version>1.6</java.version>
        <!-- 配置你的tomcat版本 -->
        <!-- <tomcat.version>7.0.55</tomcat.version> -->
    </properties>
```

如使用maven，需要maven3.2以上版本支持
程序可以部署在所有支持Servlet 3.0 以上的容器中

## 搭建项目可能遇到的错误

1. 如果使用的MyEclipse创建项目，一开始暂时不要添加javaEE6.0Library。springboot 的logback-classes-1.1.2.jar的包下有一个org.slf4j.impl包 (这是springboot真正需要的包)而MyEclipse自带的javaEE6.0library里也有一个slf4j包，会有包冲突，会一直报 NoSuchMethod异常getSingleton()。

2. 这里教大家一个快速找到class文件真正所处包的方法。
当无法确定某个类属于哪个包是   可以通过Test.class.getProtectionDomain();来查看
例如:发生noSuchMethod异常时，但是确实有该方法，一般就是重复加载了jar包。

3. 官方文档的例子都是用java7运行的。不配置<java.version>1.6</java.version>的话可能 会报版本异常的错误。类似mirro.minor什么51.0的   50表示jdk1.6   51是jdk1.7

4. 如果也不配置tomcat版本的话springboot默认会使用8.x版本的tomcat。所以要加一个
<tomcat.version>7.0.55</tomcat.version>来指定你所使用的tomcat版本(视你CATALINA_HOME配 置的所定)。



### SpringApplication  程序入口

1. 程序入口`@SpringbootApplication`相当于`@Configuration`,`@EnableAutoConfiguration`和 `@ComponentScan`

2. 可以通过`@ImportResource`方式导入xml文件。也可以run的时候加载xml的配置
`SpringApplication.run("classpath:/META-INF/application-context.xml", args);`

3. SpringApplication类提供了一种从main()方法启动Spring应用的便捷方式。在很多情况下，你只需委托给SpringApplication.run这个静态方法：
```java
public static void main(String[] args){
    SpringApplication.run(MySpringConfiguration.class, args);
}
```
4. 自动配置对程序没有影响,我们随时可以修改自己的配置来替代自动配置。例如,如果我们添加自己的数据源，那么spring默认的将不再使用。如果你一定要消除某些特定配置可以这样来，如下所示：
```java
import org.springframework.boot.autoconfigure.*;
import org.springframework.boot.autoconfigure.jdbc.*;
import org.springframework.context.annotation.*;
@Configuration
@EnableAutoConfiguration(exclude={DataSourceAutoConfiguration.class})
public class MySpringConfiguration {

}
```

### 自定义Banner (程序启动时的打印项)

通过在classpath下添加一个banner.txt或设置banner.location来指定相应的文件可以改变启动过程中打印的banner。如果这个文件有特殊的编码，你可以使用banner.encoding设置它（默认为UTF-8）。

在banner.txt中可以使用如下的变量：
| 变量|描述|
| -----|-------|  
| ${application.version} | MANIFEST.MF中声明的应用版本号，例如1.0 |
| ${application.formatted-version} | MANIFEST.MF中声明的被格式化后的应用版本号（被括号包裹且以v作为前缀），用于显示，例如(v1.0) |
| ${spring-boot.version} | 正在使用的Spring Boot版本号，例如1.2.2.BUILD-SNAPSHOT |
| ${spring-boot.formatted-version} | 正在使用的Spring Boot被格式化后的版本号（被括号包裹且以v作为前缀）, 用于显示，例如(v1.2.2.BUILD-SNAPSHOT) |

注：如果想以编程的方式产生一个banner，可以使用SpringBootApplication.setBanner(…)方法。使用org.springframework.boot.Banner接口，实现你自己的printBanner()方法。

### 自定义SpringApplication

如果默认的SpringApplication不符合你的口味，你可以创建一个本地的实例并自定义它。例如，关闭banner你可以这样写：
```java
public static void main(String[] args){
    SpringApplication app = new SpringApplication(MySpringConfiguration.class);
    app.setShowBanner(false);
    app.run(args);
}
```
注：传递给SpringApplication的构造器参数是spring beans的配置源。在大多数情况下，这些将是`@Configuration`类的引用，但它们也可能是XML配置或要扫描包的引用。

你也可以使用application.properties文件来配置SpringApplication。。查看配置选项的完整列表，可参考[SpringApplication Javadoc](http://docs.spring.io/spring-boot/docs/1.2.2.BUILD-SNAPSHOT/api/org/springframework/boot/SpringApplication.html).

### 流畅的构建API
除了通常的Spring框架的事件,如ContextRefreshedEvent SpringApplication发送一些额外的应用程序事件。触发一些事件实际上是ApplicationContext之前创建。
如果你需要创建一个分层的ApplicationContext（多个具有父子关系的上下文），或你只是喜欢使用流畅的构建API，你可以使用SpringApplicationBuilder。SpringApplicationBuilder允许你以链式方式调用多个方法，包括可以创建层次结构的parent和child方法。
```java
new SpringApplicationBuilder()
    .showBanner(false)
    .sources(Parent.class)
    .child(Application.class)
    .run(args);
```

注：创建ApplicationContext层次时有些限制，比如，Web组件(components)必须包含在子上下文(child context)中，且相同的Environment即用于父上下文也用于子上下文中。具体参考[SpringApplicationBuilder javadoc](http://docs.spring.io/spring-boot/docs/1.2.2.BUILD-SNAPSHOT/api/org/springframework/boot/builder/SpringApplicationBuilder.html)


### Application事件和监听器

除了常见的Spring框架事件，比如[ContextRefreshedEvent](http://docs.spring.io/spring/docs/4.1.4.RELEASE/javadoc-api/org/springframework/context/event/ContextRefreshedEvent.html)一个SpringApplication也发送一些额外的应用事件。一些事件实际上是在ApplicationContext被创建前触发的。

你可以使用多种方式注册事件监听器，最普通的是使用SpringApplication.addListeners(…)方法。在你的应用运行时，应用事件会以下面的次序发送：

    1. 在运行开始，但除了监听器注册和初始化以外的任何处理之前，会发送一个`ApplicationStartedEvent`。
    2. 在Environment将被用于已知的上下文，但在上下文被创建前，会发送一个`ApplicationEnvironmentPreparedEvent`。
    3. 在refresh开始前，但在bean定义已被加载后，会发送一个`ApplicationPreparedEvent`。
    4. 启动过程中如果出现异常，会发送一个`ApplicationFailedEvent`。

注：你通常不需要使用应用程序事件，但知道它们的存在会很方便（在某些场合可能会使用到）。在Spring内部，Spring Boot使用事件处理各种各样的任务。

### Web环境

一个SpringApplication将尝试为你创建正确类型的ApplicationContext。在默认情况下，使用AnnotationConfigApplicationContext或AnnotationConfigEmbeddedWebApplicationContext取决于你正在开发的是否是web应用。

用于确定一个web环境的算法相当简单（基于是否存在某些类）。如果需要覆盖默认行为，你可以使用setWebEnvironment(boolean webEnvironment)。通过调用setApplicationContextClass(…)，你可以完全控制ApplicationContext的类型。

注：当JUnit测试里使用SpringApplication时，调用setWebEnvironment(false)是可取的。

### 命令行启动器

如果你想获取原始的命令行参数，或一旦SpringApplication启动，你需要运行一些特定的代码，你可以实现CommandLineRunner接口。在所有实现该接口的Spring beans上将调用run(String… args)方法。
```java
import org.springframework.boot.*
import org.springframework.stereotype.*

@Component
public class MyBean implements CommandLineRunner {
    public void run(String... args) {
        // Do something...
    }
}
```
如果一些CommandLineRunner beans被定义必须以特定的次序调用，你可以额外实现org.springframework.core.Ordered接口或使用org.springframework.core.annotation.Order注解。

### Application退出

每个SpringApplication在退出时为了确保ApplicationContext被优雅的关闭，将会注册一个JVM的shutdown钩子。所有标准的Spring生命周期回调（比如，DisposableBean接口或@PreDestroy注解）都能使用。

此外，如果beans想在应用结束时返回一个特定的退出码（exit code），可以实现org.springframework.boot.ExitCodeGenerator接口。

SpringApplication.exit(this.context);
