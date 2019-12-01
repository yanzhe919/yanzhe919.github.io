title: 使用jaxb接口的实现和一些Tips
date: 2016-02-27 14:08:05
tags: [Java,JAXB]
categories: Java
description: Java对象持有接口时组建XML报文，以及一些其他使用JAXB的小技巧
---

JAXB（Java API for XML Binding），提供了一个快速便捷的方式将Java对象与XML进行转换。在JAX-WS（Java的WebService规范之一）中，JDK1.6 自带的版本JAX-WS2.1，其底层支持就是JAXB。JAXB 2.0是JDK 1.6的组成部分。JAXB 2.2.3是JDK 1.7的组成部分。

    JAXB 可以实现Java对象与XML的相互转换，在JAXB中，将一个Java对象转换为XML的过程称之为Marshal，将XML转换为Java对象的过程称之为UnMarshal。



## JAXB中的一些注解
  JDK中JAXB相关的重要Class和Interface：

  1、JAXBContext类，是应用的入口，用于管理XML/Java绑定信息。

  2、Marshaller接口，将Java对象序列化为XML数据。

  3、Unmarshaller接口，将XML数据反序列化为Java对象。
 

  JDK中JAXB相关的重要Annotation：

  1、@XmlType，将Java类或枚举类型映射到XML模式类型。用在class类的注解，常与@XmlRootElement，@XmlAccessorType一起使用。

  2、@XmlAccessorType(XmlAccessType.FIELD) ，控制字段或属性的序列化。FIELD表示JAXB将自动绑定Java类中的每个非静态的（static）、非瞬态的（由@XmlTransient标注）字段到XML。其他值还有XmlAccessType.PROPERTY和XmlAccessType.NONE。

  3、@XmlAccessorOrder，控制JAXB 绑定类中属性和字段的排序。

    AccessorOrder.ALPHABETICAL：对生成的xml元素按字母书序排序

　　XmlAccessOrder.UNDEFINED:不排序

    当同时使用@XmlType的propOrder属性指定顺序时，以指定为准

  4、@XmlJavaTypeAdapter，使用定制的适配器（即扩展抽象类XmlAdapter并覆盖marshal()和unmarshal()方法），以序列化Java类为XML。

  5、@XmlElementWrapper ，对于数组或集合（即包含多个元素的成员变量），生成一个包装该数组或集合的XML元素（称为包装器）。

  6、@XmlRootElement，将Java类或枚举类型映射到XML元素。

  7、@XmlElement，将Java类的一个属性映射到与属性同名的一个XML元素。

  8、@XmlAttribute，将Java类的一个属性映射到与属性同名的一个XML属性。

## Mapping interfaces

因为W3C XML Schema和Java类型系统引起的XML类型系统之间的差异，JAXB不能绑定接口开箱即用，但也有一些事情可以做。

### 使用@XmlRootElement
```java
@XmlRootElement
class Zoo {
  @XmlAnyElement
  public List<Animal> animals;
}

interface Animal {
  void sleep();
  void eat();
  ...
}

@XmlRootElement
class Dog implements Animal { ... }

@XmlRootElement
class Lion implements Animal { ... }
```

```xml
<zoo>
    <lion> ... </lion>
    <dog> ... </dog>
</zoo>
```

这种方法的主要特点是：

1. 实现是开放式的; 任何人都可以实现这些接口，即使由不同的人从不同的模块，只要它们都被提供给JAXBContext.newInstance方法。没有必要列出的任何地方都实现类。
2. 每个接口的实现都需要有一个独特的元素名称。
3. 为每个接口参考需要有 XmlElementRef将 注释。该类型= Object.class部分告诉JAXB所有实现最大的公共基类是java.lang.Object继承。

分组，列表
```java
@XmlRootElement
class Zoo {
  @XmlElementWrapper
  @XmlAnyElement
  public List<Animal> onExhibit;
  @XmlElementWrapper
  @XmlAnyElement
  public List<Animal> resting;
}
```

```xml
<zoo>
    <onExhibit>
        <lion> ... </lion>
        <dog> ... </dog>
    </onExhibit>
    <resting>
        <lion> ... </lion>
        <dog> ... </dog>
    </resting>
</zoo>
```


### 使用@XmlJavaTypeAdapter

```java
@XmlJavaTypeAdapter(FooImpl.Adapter.class)
interface IFoo {
  ...
}
class FooImpl implements IFoo {
  @XmlAttribute
  private String name;
  @XmlElement
  private int x;
  
  ...
  
  static class Adapter extends XmlAdapter<FooImpl,IFoo> {
    IFoo unmarshal(FooImpl v) { return v; }
    FooImpl marshal(IFoo v) { return (FooImpl)v; }
  }
}

class Somewhere {
  public IFoo lhs;
  public IFoo rhs;
}
```

```xml
<somewhere>
  <lhs name="...">
    <x>5</x>
  </lhs>
  <rhs name="...">
    <x>5</x>
  </rhs>
</somewhere>
```

这种方法的主要特点是：

1. 接口和实现将通过一个适配器紧密结合，虽然改变适配器代码将允许您支持多种实现。
2. 有在使用接口，无需任何注释。
这种技术的一个变化是，当你有几个实现接口，不只是一个。

```java
@XmlJavaTypeAdapter(AbstractFooImpl.Adapter.class)
interface IFoo {
  ...
}
abstract class AbstractFooImpl implements IFoo {
  ...
  
  static class Adapter extends XmlAdapter<AbstractFooImpl,IFoo> {
    IFoo unmarshal(AbstractFooImpl v) { return v; }
    AbstractFooImpl marshal(IFoo v) { return (AbstractFooImpl)v; }
  }
}

class SomeFooImpl extends AbstractFooImpl {
  @XmlAttribute String name;
  ...
}

class AnotherFooImpl extends AbstractFooImpl {
  @XmlAttribute int id;
  ...
}

class Somewhere {
  public IFoo lhs;
  public IFoo rhs;
}
```

```xml
<somewhere>
  <lhs xsi:type="someFooImpl" name="...">
  </lhs>
  <rhs xsi:type="anotherFooImpl" id="3" />
</somewhere>
```

需要注意的是SomeFooImpl和AnotherFooImpl必须提交JAXBContext.newInstance一种方式或其他。

再举这个例子，你可以使用Object而不是AbstractFooImpl。如下
```java
@XmlJavaTypeAdapter(AnyTypeAdapter.class)
interface IFoo {
  ...
}
public class AnyTypeAdapter extends XmlAdapter<Object,Object> {
  Object unmarshal(Object v) { return v; }
  Object marshal(Object v) { return v; }
}

class SomeFooImpl implements IFoo {
  @XmlAttribute String name;
  ...
}

class Somewhere {
  public IFoo lhs;
  public IFoo rhs;
}
```
```xml
<xs:complexType name="somewhere">
  <xs:sequence>
    <xs:element name="lhs" type="xs:anyType" minOccurs="0"/>
    <xs:element name="rhs" type="xs:anyType" minOccurs="0"/>
  </xs:sequence>
</xs:complexType>
```
正如你所看到的，模式将产生接受的xs：anyType的它比Java代码实际上需要更多的宽松。实例将是与上述相同的例子。从JAXB 2.1 RI开始，我们捆绑com.sun.xml.bind.AnyTypeAdapter在定义该适配器的运行时类。所以，你将不必编写此适配器在你的代码。

### 使用@XmlElement
```java
interface IFoo {
  ...
}
class FooImpl implements IFoo {
  ...
}

class Somewhere {
  @XmlElement(type=FooImpl.class)
  public IFoo lhs;
}
```
```xml
<somewhere>
  <lhs> ... </lhs>
</somewhere>
```
这实际上告诉JAXB运行时说：“即使字段是IFoo的，它实际上只是FooImpl。

在这种方法中，一个接口的引用必须具有实际实现类的知识。因此，尽管这需要输入最少的，它可能不会，如果这跨越模块的边界工作得很好。

像 XmlJavaTypeAdapter 方法，这可以甚至当存在多个实施方式中，只要它们共享共同的祖先中。

这种情况下的极端是指定@XmlElement（类型= Object.class） 。

## Tips

### 指定XML字段顺序

默认JAXB生成的XML字段是随机的，可以使用注解`@XmlType`的`propOrder`属性来指定XML字段的顺序。

```java
@XmlType(propOrder = { "user", "profile","unit"})
```

另外，使用`@XmlElementWrapper`标注的属性，不能出现在`@XmlType`的`propOrder`列表中。但是对于使用`@XmlElement`标注的属性，则必须出现在该列表中

### 集合中省略集合节点名 

```xml
    //Example: code fragment
      int[] names;

    // XML Serialization Form 1 (Unwrapped collection)
    <names> ... </names>
    <names> ... </names>
 
    // XML Serialization Form 2 ( Wrapped collection )
    <wrapperElement>
       <names> value-of-item </names>
       <names> value-of-item </names>
       ....
    </wrapperElement>
```
The [docs](http://docs.oracle.com/javaee/5/api/javax/xml/bind/annotation/XmlElementWrapper.html) state the the @XmlElementWrapper annotation can be used for 'unwrapped' or 'wrapped' collections.


If you include @XmlElementWrapper it will add a grouping element:
```java
@XmlElementWrapper
@XmlElement(name="foo")
public List<Foo> getFoos() {
    return foos;
}
```

```xml
<root>
    <foos>
        <foo/>
        <foo/>
    </foos>
</foo>
```
and if you omit it, then it won't.

```java
@XmlElement(name="foo")
public List<Foo> getFoos() {
    return foos;
}
```
```xml
<root>
    <foo/>
    <foo/>
</foo>
```

另外，`@XmlElementWrapper`仅允许出现在集合属性上。

[stackoverflow地址](http://stackoverflow.com/questions/16202583/xmlelementwrapper-for-unwrapped-collections)

### 转为XML文件时移除xmlns:xsi和xsi:type

How to remove xmlns:xsi and xsi:type from JAXB marshalled XML file

使用`@XmlElement`指定`Type`类型
```java
  @XmlElement(name = "DefaultCar", type=String.class) 
  protected Object defaultcar;  

  @XmlElement(name = "dir", type=Dir.class)
  private ArrayList dirs = null;
```

在List中如果每个对象，类型不同，对象转XML时，可以用
```java
@XmlElementRefs({
        @XmlElementRef(name="data", type=A.class),
        @XmlElementRef(name="data", type=B.class),
        @XmlElementRef(name="data", type=C.class),
        @XmlElementRef(name="data", type=D.class)})
```
但是在XML转换为对象时，这边可能需要额外判断一下，直接转换时，如果XML节点元素都为<data xsi:type="">，指定了type，也可能会报错。

### XmlElementRef的一些使用
@XmlElementRef annotation can be used with a JavaBean property or from within @XmlElementRefs
```java
    @XmlElementRefs({
        @XmlElementRef(name="data", type=A.class),
        @XmlElementRef(name="data", type=B.class),
        @XmlElementRef(name="data", type=C.class),
        @XmlElementRef(name="data", type=D.class)})
```

XML Schema substitution group support

The usage is subject to the following constraints:

1.  If the collection item type (for collection property) or property type (for single valued property) is JAXBElement, then @XmlElementRef}.name() and @XmlElementRef.namespace() must point an element factory method with an @XmlElementDecl annotation in a class annotated with @XmlRegistry (usually ObjectFactory class generated by the schema compiler) :
    (1).  @XmlElementDecl.name() must equal @XmlElementRef.name()
    (2).  @XmlElementDecl.namespace() must equal @XmlElementRef.namespace().
2. If the collection item type (for collection property) or property type (for single valued property) is not JAXBElement, then the type referenced by the property or field must be annotated with XmlRootElement.
3. This annotation can be used with the following annotations: XmlElementWrapper, XmlJavaTypeAdapter.

#### Example 1: Ant Task Example
The following Java class hierarchy models an Ant build script. An Ant task corresponds to a class in the class hierarchy. The XML element name of an Ant task is indicated by the `@XmlRootElement` annotation on its corresponding class.
```java
     @XmlRootElement(name="target")
     class Target {
         // The presence of @XmlElementRef indicates that the XML
         // element name will be derived from the @XmlRootElement 
         // annotation on the type (for e.g. "jar" for JarTask). 
         @XmlElementRef
         List<Task> tasks;
     }

     abstract class Task {
     }

     @XmlRootElement(name="jar")
     class JarTask extends Task {
         ...
     }

     @XmlRootElement(name="javac")
     class JavacTask extends Task {
         ...
     }
```
```xml
     <!-- XML Schema fragment -->
     <xs:element name="target" type="Target">
     <xs:complexType name="Target">
       <xs:sequence>
         <xs:choice maxOccurs="unbounded">
           <xs:element ref="jar">
           <xs:element ref="javac">
         </xs:choice>
       </xs:sequence>
     </xs:complexType>
```
 
Thus the following code fragment:
```java
     Target target = new Target();
     target.tasks.add(new JarTask());
     target.tasks.add(new JavacTask());
     marshal(target);
``` 
will produce the following XML output:
```xml
     <target>
       <jar>
         ....
       </jar>
       <javac>
         ....
       </javac>
     </target>
```
It is not an error to have a class that extends Task that doesn't have `XmlRootElement`. But they can't show up in an XML instance (because they don't have XML element names).

#### Example 2: XML Schema Susbstitution group support
The following example shows the annotations for XML Schema substitution groups. The annotations and the ObjectFactory are derived from the schema.
```java
     @XmlElement
     class Math {
         //  The value of type()is 
         //  JAXBElement.class , which indicates the XML
         //  element name ObjectFactory - in general a class marked
         //  with @XmlRegistry. (See ObjectFactory below)
         //  
         //  The name() is "operator", a pointer to a
         // factory method annotated with a
         //  XmlElementDecl with the name "operator". Since
         //  "operator" is the head of a substitution group that
         //  contains elements "add" and "sub" elements, "operator"
         //  element can be substituted in an instance document by
         //  elements "add" or "sub". At runtime, JAXBElement
         //  instance contains the element name that has been
         //  substituted in the XML document.
         // 
         @XmlElementRef(type=JAXBElement.class,name="operator")
         JAXBElement<? extends Operator> term;
     }

     @XmlRegistry
     class ObjectFactory {
         @XmlElementDecl(name="operator")
         JAXBElement<Operator> createOperator(Operator o) {...}
         @XmlElementDecl(name="add",substitutionHeadName="operator")
         JAXBElement<Operator> createAdd(Operator o) {...}
         @XmlElementDecl(name="sub",substitutionHeadName="operator")
         JAXBElement<Operator> createSub(Operator o) {...}
     }

     class Operator {
         ...
     }
 
//Thus, the following code fragment

     Math m = new Math();
     m.term = new ObjectFactory().createAdd(new Operator());
     marshal(m);
``` 
will produce the following XML output:
```xml
     <math>
       <add>...</add>
     </math>
```

### nil 属性和其他属性
XML 架构规范允许其他 XML 属性出现在 xsi:nil 属性设置为 true 的元素中。由于只有当对应的对象被分配了空引用时，XmlSerializer 类才将 nil 属性设置为 true，因此，表示 XML 属性（通过类型为 System.Xml.Serialization.XmlAttributeAttribute 的属性）的任何对象字段此时甚至不能存在于内存中。

因此，XmlSerializer 类按如下方式处理其他属性：

1. 在将对象序列化为 XML 文档时：如果 XmlSerializer 类遇到与某个 XML 元素对应的对象的空引用，并且应当为该元素指定 nil 属性，则它会省略任何其他属性。

2. 在将 XML 文档反序列化为对象时：如果 XmlSerializer 类遇到指定 xsi:nil="true" 的 XML 元素，它会为对应的对象分配一个空引用，并忽略其他任何属性。如果该 XML 文档是由某个 XML 架构实现创建的，而且该实现允许其他属性与 xsi:nil="true" 一起出现 — 实际上是不将 nil 的 true 值绑定到空对象引用 — 则可能会出现这种情况。

### XSD文件中的<Choice>使用
These sequence tags will be under <Choice> tag. Now either of these set of tags (Sequence) will be validated.
```xml
<?xml version="1.0" encoding="utf-8"?>
<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="root" type="root"/>
  <xs:complexType name="root">
    <xs:choice>
      <xs:sequence>
        <xs:element name="empno" type="xs:string" />
        <xs:element name="designation" type="xs:string" />
      </xs:sequence>
      <xs:sequence>
        <xs:element name="name" type="xs:string" />
        <xs:element name="age" type="xs:unsignedByte" />
      </xs:sequence>
    </xs:choice>
  </xs:complexType>
</xs:schema>
```
一般建议使用如下
```xml
<?xml version="1.0" encoding="utf-8"?>
<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="root" type="root"/>

  <xs:complexType name="root">
    <xs:sequence>
      <xs:element name="trunk" type="trunk"/>
      <xs:element name="other" type="xs:string" />
    </xs:sequence>
  </xs:complexType>

  <xs:complexType name="trunk">
    <xs:sequence>
      <xs:element name="branch1" type="xs:string"/>
      <xs:element name="branch2" type="xs:string"/>
    </xs:sequence>
  </xs:complexType>
</xs:schema>
```

### Xml Schema的派生复杂类型 

XML Schema提供了一种机制，称为替换组（substitution group），允许在内容模型中声明的某个元素被其他元素所替换。替换组有头元素（head element）和替换成员组成，头元素和替换成员都必须是全局元素，有相同的类型，或都有头元素派生。替换成员需要使用一个特殊的属性sbustitutionGroup，用于指定要替换的头元素的名字。在内容模型中引用头元素，在实例文档中则用任意的替换组成员来替换头元素。详见[他人博客](http://blog.csdn.net/tuolingss/article/details/8550090)

### 使用JDK中的xjc.exe命令，根据xsd文件生成java代码
实际上，有更懒的办法。
写好一个xsd文件，然后用jdk下bin `xjc.exe test-scheme.xsd -d [your src dir] `命令自动生成java等文件。也可以用IDE，像eclipse 选中xsd右键-> Genarate -> JAXB Class生成 。在eclipse中，要先让项目运行环境在JDK 1.6 或以上。如默认项目运行在JRE，需要手工更改Build path为JDK

关于 xjc.exe For more info use [this documentation](http://docs.oracle.com/javaee/5/tutorial/doc/bnazg.html)

and [this](http://docs.oracle.com/javase/6/docs/technotes/tools/share/xjc.html)

如果生成的根元素对应的对象没有自动添加上`@XmlRootElement`，则需要手动添加。
