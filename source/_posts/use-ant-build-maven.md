title: 使用ant打包maven项目
date: 2015-09-17 16:35:29
tags: [Java,maven]
categories: Java
description: 用ant打包maven项目，子工程打包成jar包，最后打成一个war包。(暂没解决互相依赖的情况)
---

问题很奇怪，估计没啥雷同的了。
简单来说，要求必须用ant打包maven项目。
最终只需一个war包，其他项目打成jar包，放在war包中。

## 在每个maven子项目中，建立一个用于ant buildfile的xml。


```xml
	<!-- 源文件目录 -->
	<property name="src.dir.core" value="src/main/java" />
	<!-- 编译jar文件目录 -->
	<property name="jar.dir.core" value="../compile_lib" />
	<property name="j2eejar.dir.core" value="../j2ee_lib" />
	<!-- WEB文件目录 -->
	<property name="web.dir.core" value="src/main/webapp" />
	<!-- config || output address -->
	<property name="config.dir.core" value="src/main/resource" />
	<!-- jar文件存放目录 -->
	<property name="dist.dir.core" value="../compile_lib" />
	<!-- 编译文件存放目录 -->
	<property name="build.dir.core" value="build" />
	<!-- 生成应用名 -->
	<property name="webapp.name.core" value="jar包文件名" />
	<!-- 编译环境 -->
	<property environment="env" />
	<path id="classpath.core">
		<fileset dir="${jar.dir.core}">
			<include name="*.jar" />
		</fileset>
		<fileset dir="${j2eejar.dir.core}">
			<include name="*.jar" />
		</fileset>
		<pathelement path="${build.dir.core}" />
	</path>
	<target name="RUN_PACKAGE" description="Packages app as JAR">
		<echo message="正在清空编译目录，生成目录..."/>
		<delete dir="${build.dir.core}/classes"/>
		<delete file="${dist.dir.core}/${webapp.name.core}.jar"/>
		<echo message="正在创建编译目录...."/>
		<mkdir dir="${build.dir.core}/classes" />
		<javac destdir="${build.dir.core}/classes" debug="false" deprecation="false" optimize="true" failonerror="true">
			<compilerarg line="-encoding UTF-8"/>
			<src path="${src.dir.core}"/>
			<classpath refid="classpath.core" />
		</javac>
		<echo message="正在编译文件目录...."/>
		<!-- Copy config files to ${build.dir.core}/classes -->
		<antcall target="DELETE-PAGES"/>
		<antcall target="COPY-PAGER"/>
		<antcall target="COPY-TLD"/>
		<echo message="正在生成JAR包..."/>
		<!-- 打jar包时，导入哪些配置，不导入哪些配置-->
		<jar destfile="${dist.dir.core}/${webapp.name.core}.jar" basedir="${build.dir.core}/classes" >
			<fileset dir="${src.dir.core}">
				<include name="**/*.properties" />
				<include name="**/*.xml" />
				<include name="**/*.tld" />
				<include name="**/*.ftl" />
				<include name="**/*.jasper" />
				<include name="**/*.jrxml" />
				<exclude name="**/*.java" />
			</fileset>	
		</jar>	
		<echo message="清理相关编译文件..."/>
		<delete dir="${build.dir.core}/classes"/>
	</target>
	<!--删除指定路径下文件及目录-->
	<target name="DELETE-PAGES" >
		<property name="delete_path_core" value="${build.dir.core}\classes\someproject\"/>
		<echo>----------------------------------START------------------------------------</echo>
		<echo>开始删除${delete_path_core}下文件</echo>
		<delete dir="${delete_path_core}"/>  
		<echo>删除完成</echo>
		<echo>-----------------------------------END-----------------------------------</echo>
	</target>
	<!--COPY PAGES到指定路径下-->
	<target name="COPY-PAGER" >
		<!--调用删除-->
		<antcall target="DELETE-PAGES">
				<param name="delete_path_core" value="${build.dir.core}\classes\someproject\resource\"/>
		</antcall>
		<!--webapp 页面路径 -->
		<property name="pager_path_core" location="${web.dir.core}\pages\ylink\someproject\" />
		<property name="script_path_core" location="${web.dir.core}\script\someproject\" />
		<property name="style_path_core" location="${web.dir.core}\style\" />
		<property name="to_pager_path_core" location="${build.dir.core}\classes\someproject\resource\pages" />
		<property name="to_script_path_core" location="${build.dir.core}\classes\someproject\resource\script\someproject" />
		<property name="to_style_path_core" location="${build.dir.core}\classes\someproject\resource\style" />
		<echo>-----------------------------------START-----------------------------------</echo>
		<echo>(${pager_path_core})----------->(${to_pager_path_core})</echo>
		<echo>开始拷贝JSP页面</echo>
		<copy todir="${to_pager_path_core}">
			<fileset dir="${pager_path_core}">
				<exclude name="someproject2/**" />
			</fileset>
		</copy>
		<echo>JSP页面拷贝结束</echo>
		<echo>开始拷贝scirpt</echo>
		<copy todir="${to_script_path_core}">
			<fileset dir="${script_path_core}">
				<include name="*/**" />
			</fileset>
		</copy>
		<echo>script脚本拷贝结束</echo>
		<echo>开始拷贝style</echo>
		<copy todir="${to_style_path_core}">
			<fileset dir="${style_path_core}">
				<include name="*/**" />
			</fileset>
		</copy>
		<echo>style样式拷贝结束</echo>	
		<echo>开始拷贝resource文件</echo>
		<copy todir="${build.dir.core}/classes">
			<fileset dir="${config.dir.core}">
				<include name="*/**" />
				<exclude name="**/jdbc*.properties" />
			    <exclude name="**/mqconfig*.properties" />
			    <exclude name="**/messages*.properties" />
			    <exclude name="**/system*.properties" />
			    <exclude name="**/cache*.properties" />
			    <exclude name="**/report*.properties" />
			    <exclude name="**/upload*.properties" />
				<exclude name="**/webinit-extend*.properties" />
			    <exclude name="**/logback*.xml" />
			    <exclude name="**/struts*.xml" />
			    <exclude name="**/layout*.xml" />
			</fileset>
		</copy>
		<echo>resource文件拷贝结束</echo>	
		<echo>-------------------------------------END---------------------------------</echo>
	</target>
	<!--COPY TLD到指定路径下-->
	<target name="COPY-TLD" >
		<!--调用删除-->
		<antcall target="DELETE-PAGES">
	            <param name="delete_path_core" value="${build.dir.core}\classes\someproject\tlds\"/>
	    </antcall>
		<property name="pager_path_core" location="${web.dir.core}\WEB-INF\tlds\" />
		<property name="to_path_core" location="${build.dir.core}\classes\someproject\tlds\" />
		<echo>-----------------------------------START-----------------------------------</echo>
		<echo>(${pager_path_core})----------->(${to_path_core})</echo>
		<echo>开始拷贝TLD文件</echo>
		<copy todir="${to_path_core}">
	        <fileset dir="${pager_path_core}">
	          	<include name="*/**" />
	        </fileset>
	    </copy>
		<echo>TLD文件拷贝结束</echo>
		<echo>-------------------------------------END---------------------------------</echo>
	</target>
	
```


## 打war包xml可运行其他jar包xml，然后打war包。

互相依赖的关系，没有解决。如，A依赖B，B依赖A
作弊的方法是，已有A/Bjar包。
唉，这方法其实没啥记录的必要。熟悉下ant和maven好了。




```xml
	<?xml version="1.0" encoding="UTF-8"?>
	<project name="项目名" basedir="." default="main">
	<!-- 源文件目录 -->
	<property name="src.dir" value="src/main/java" />
	<!-- 编译jar文件目录 -->
	<property name="jar.dir" value="../compile_lib" />
	<!-- WEB文件目录 -->
	<property name="web.dir" value="src/main/webapp" />
	<!-- config || output address -->
	<property name="config.dev.dir" value="../config/dev" />
	<property name="config.dir" value="src/main/resource" />
	<!-- jar文件存放目录 -->
	<property name="dist.dir" value="../dist" />
	<property name="dist.dev.dir" value="../dist/dev" />
	<!-- 编译文件存放目录 -->
	<property name="build.dir" value="build" />
	<!-- 生成应用名 -->
	<property name="webapp.name" value="项目名" />
	<property environment="env" />
	<path id="classpath">
		<fileset dir="${jar.dir}">
			<include name="*.jar" />
		</fileset>
		<pathelement path="${build.dir}" />
	</path>	
	<!-- 构建子工程XXXX任务 -->
	<target name="子工程">
		<echo message="构建子工程「XXXX」！"/>
		<ant  dir="../XXXX"/>
	</target>	
	<!-- 生成war包 命令: ant -buildfile build.xml -->
	<target name="RUN_PACKAGE" depends="子工程,子工程2" description="Packages app as WAR">
		<echo message="正在清空编译目录，生成目录..."/>
		<delete dir="${build.dir}/classes"/>
		<delete dir="${build.dir}/lib"/>
		<delete file="${dist.dir}/${webapp.name}.war"/>
		<echo message="正在创建编译目录...."/>
		<mkdir dir="${build.dir}/classes" />
		<javac destdir="${build.dir}/classes" debug="false" deprecation="false" optimize="true" failonerror="true">
			<compilerarg line="-encoding UTF-8"/>
			<src path="${src.dir}"/>
			<classpath refid="classpath" />
		</javac>
		<echo message="正在编译文件目录...."/>
		<!-- Copy config files to ${build.dir}/classes -->
		<copy todir="${build.dir}/classes">
			<fileset dir="${config.dir}" includes="**/*.*" />
		</copy>
		<copy todir="${build.dir}/classes">
			<fileset dir="${src.dir}" includes="**/*.*" excludes="**/*.java" />
		</copy>
		<copy todir="${build.dir}/lib">
			<fileset dir="${jar.dir}" includes="**/*.*" />
		</copy>
		<echo message="正在生成WAR包..."/>
		<war destfile="${dist.dir}/${webapp.name}.war" webxml="${web.dir}/WEB-INF/web.xml">
			<classes dir="${build.dir}/classes" />
			<lib dir="${build.dir}/lib" />
			<fileset dir="${web.dir}">
				<include name="**/*.*" />
				<exclude name="**/classes/**/*.*"/>
				<exclude name="**/web.xml" />
			</fileset>
		</war>
		<echo message="清理相关编译文件..."/>
		<delete dir="${build.dir}/classes"/>
		<delete dir="${build.dir}/lib"/>
	</target>
	<target name="DEV" depends="子工程,子工程2" description="Packages app as WAR  DEV">
		<echo message="正在清空编译目录，生成目录..."/>
		<delete dir="${build.dir}/classes"/>
		<delete dir="${build.dir}/lib"/>
		<delete file="${dist.dev.dir}/${webapp.name}.war"/>
		<echo message="正在创建编译目录...."/>
		<mkdir dir="${build.dir}/classes" />
		<javac destdir="${build.dir}/classes" debug="false" deprecation="false" optimize="true" failonerror="true">
			<compilerarg line="-encoding UTF-8"/>
			<src path="${src.dir}"/>
			<classpath refid="classpath" />
		</javac>
		<echo message="正在编译文件目录...."/>
		<!-- Copy config files to ${build.dir}/classes -->
		<copy todir="${build.dir}/classes">
			<fileset dir="${config.dev.dir}" includes="**/*.*"/>
		</copy>
		<copy todir="${build.dir}/classes">
			<fileset dir="${config.dir}" includes="**/*.*" />
		</copy>
		<copy todir="${build.dir}/classes">
			<fileset dir="${src.dir}" includes="**/*.*" excludes="**/*.java" />
		</copy>
		<copy todir="${build.dir}/lib">
			<fileset dir="${jar.dir}" includes="**/*.*" />
		</copy>
		<echo message="正在生成WAR包..."/>
		<war destfile="${dist.dev.dir}/${webapp.name}.war" webxml="${web.dir}/WEB-INF/web.xml">
			<classes dir="${build.dir}/classes" />
			<lib dir="${build.dir}/lib" />
			<fileset dir="${web.dir}">
				<include name="**/*.*" />
				<exclude name="**/classes/**/*.*"/>
				<exclude name="**/web.xml" />
			</fileset>
		</war>
		<echo message="清理相关编译文件..."/>
		<delete dir="${build.dir}/classes"/>
		<delete dir="${build.dir}/lib"/>
	</target>
	<!-- 默认任务 -->
	<target name="main" depends="RUN_PACKAGE"/>
</project>
	
```	