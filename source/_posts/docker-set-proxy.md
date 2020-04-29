title: Docker设置socks5代理或使用国内镜像
date: 2017-11-09 11:34:01
tags: [Docker,SS,proxy]
categories: Docker
description: 创建目录`mkdir -p /etc/systemd/system/docker.service.d`,创建`https-proxy.conf`文件，并添加`HTTP_PROXY`,或`HTTPS_PROXY` `NO_PROXY`环境变量。更新配置`sudo systemctl daemon-reload`，重启Docker服务`sudo systemctl restart docker`。
---

Dockers是有能力打包应用程式及其虚拟容器，可以在任何Linux伺服器上执行的依赖性工具，这有助於实现灵活性和便携性，应用程式在任何地方都可以执行，无论是公有云、私有云、单机等。
[docker是什么](https://www.docker.com/what-docker).

## 安装Docker
如果可以直接连接docker官网，可以直接使用以下命令安装。一条命令直接安装docker。
```
curl -sSL https://get.docker.com/ | sh
```
如果以上安装失败，可以下载脚本后 [install_docker.sh](install_docker.sh) 执行`sh --mirror Aliyun`
或
```
sudo wget http://blog.yanzhe.tk/2017/11/09/docker-set-proxy/install_docker.sh | sh --mirror Aliyun
```

如需要设置非root用户自启docker，需要将目标用户添加到docker分组，即是现在安装docker后会出现的提示
```
sudo usermod -aG docker $USER
```

docker安装后出现Cannot connect to the Docker daemon.一般重启docker即可
```shell
service docker start
```

## Docker 设置http,https socks5代理

1. 为docker服务创建一个内嵌的systemd目录

```shell
mkdir -p /etc/systemd/system/docker.service.d
```

2. 创建/etc/systemd/system/docker.service.d/https-proxy.conf文件，并添加HTTP_PROXY,或HTTPS_PROXY环境变量。

```shell
cd /etc/systemd/system/docker.service.d
sudo nano https-proxy.conf
```
其中ip和port,NO_PROXY分别改成实际情况的代理地址和端口：
https-proxy.conf
```shell
[Service]
Environment="HTTP_PROXY=socks5://127.0.0.1:1080/" "HTTPS_PROXY=socks5://127.0.0.1:1080/" "NO_PROXY=localhost,127.0.0.1,docker.io,yanzhe919.mirror.aliyuncs.com,99nkhzdo.mirror.aliyuncs.com,*.aliyuncs.com,*.mirror.aliyuncs.com,registry.docker-cn.com,hub.c.163.com,hub-auth.c.163.com,"
```

3. 更新配置：

```shell
sudo systemctl daemon-reload 
```

4. 重启Docker服务：

```shell
sudo systemctl restart docker
```

## 如使用国内镜像，可用

### docker pull 完整路径(网址/name/repo:tag)

 您可以使用以下命令直接从该镜像加速地址进行拉取：

`docker pull registry.docker-cn.com/myname/myrepo:mytag`

例如:
```shell
docker pull registry.docker-cn.com/library/ubuntu:16.04
```

### 使用 --registry-mirror 配置 Docker 守护进程

您可以配置 Docker 守护进程默认使用 Docker 官方镜像加速。这样您可以默认通过官方镜像加速拉取镜像，而无需在每次拉取时指定 `registry.docker-cn.com`。

您可以在 Docker 守护进程启动时传入 `--registry-mirror` 参数：
```shell
docker --registry-mirror=https://registry.docker-cn.com daemon
```
为了永久性保留更改，您可以修改 `/etc/docker/daemon.json` 文件并添加上 `registry-mirrors` 键值。
```shell
{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}
```
修改保存后重启 Docker 以使配置生效。
```
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker
```


阿里，使用需要登录自己的阿里账号，配置自己的地址
```shell
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://99nkhzdo.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker
```

## docker 基本使用示例

### docker 安装并运行nginx

> * 检查本地镜像

    `docker images`

> * 拉取镜像

    `docker pull nginx` 或是使用dockerfile文件build images

> * 运行容器，可指定后台运行-d，指定映射端口-p 主机:容器内，指定挂载目录-v 主机:容器内

可COPY nginx默认配置文件
```shell
mkdir -p ~/nginx/www ~/nginx/logs ~/nginx/conf
cd ~/nginx
docker run --name mynginx -d library/nginx
docker cp mynginx:/etc/nginx/nginx.conf /home/yanzhe/nginx/conf/nginx.conf
docker run -p 80:80 --name mynginx -v $PWD/www:/www -v $PWD/conf/nginx.conf:/etc/nginx/nginx.conf -v $PWD/logs:/wwwlogs  -d nginx
```

> * 查看容器状态

    -a所有
    `docker ps -a`

> * 查看端口是否监听

    `ss -na | grep :80`

    或是
    `netstat -na | grep 80`

> * 查看容器日志

    `docker logs mynginx`

> * 进入容器

    `docker exec -it mynginx bash`

> * 访问web

    `http://localhost:80`

> * 停止容器

    `docker stop mynginx`

> * 启动/重启容器

    `docker start mynginx` `docker restart mynginx`

> * 删除容器

    `dockert rm mynginx`

### docker 

### 使用war包，tomcat

> * 拉取tomcat

        `docker pull library/tomcat`

> * 使用dockerfile

将war包与dockerfile放置于同级目录，创建dockerfile

    ```shell
    ##from 基础镜像,images name
    from library/tomcat

    ##制作者信息
    MAINTAINER yanzhe yz@gmail.com

    COPY jpress.war /usr/local/tomcat/webapps
    ```

> * build dockerfile

    -t 指定name:tag
    `docker build -t jpress:latest`

> * 运行容器

    `docker run -d -p 8888:8080 jpress`

> * 查看端口是否监听

    `ss -na | grep 8888`

    或是
    `netstat -na | grep 8888`

> * 访问tomcat

    `http://localhost:8888/jpress`

### spring boot 

> * 添加 Dockerfile

在应用根目录下建立 Dockerfile 文件，内容如下：

```shell
FROM maven:3.3.3

ADD pom.xml /tmp/build/
RUN cd /tmp/build && mvn -q dependency:resolve

ADD src /tmp/build/src
        #构建应用
RUN cd /tmp/build && mvn -q -DskipTests=true package \
        #拷贝编译结果到指定目录
        && mv target/*.jar /app.jar \
        #清理编译痕迹
        && cd / && rm -rf /tmp/build

VOLUME /tmp
EXPOSE 8080
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
```

由于项目使用 Maven 构建，故本次基础镜像选用 maven:3.3.3  官方镜像。
官方维护的 Maven 镜像依赖于 Java 镜像构建，所以我们不需要使用 Java 镜像。

因为 Spring Boot 框架打包的应用是一个包含依赖的 jar 文件，内嵌了 Tomcat 和 Jetty 支持，所以我们只需要使用包含 Java 的 Maven 镜像即可，不需要 Tomcat 镜像。

为了减少镜像大小，在执行 Maven 构建之后，清理了构建痕迹。

在 Dockerfile 文件的最后，使用 ENTRYPOINT  指令执行启动 Java 应用的操作。

> * 构建docker镜像

    `docker build -t docker-demo-spring-boot . `

> * 从镜像启动容器

    `docker run -d -p 8080:8080 docker-demo-spring-boot`

> * 打开浏览器，或者使用 curl 访问如下地址

    `http://127.0.0.1:8080`
