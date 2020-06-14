---
layout: post
title: Docker 多阶段构建示例 + Docker Hexo
date: 2020-06-13 08:23:03
tags:
 - docker
 - hexo
 - multi-stage build
 - 多阶段构建
categories:
 - docker
 - hexo
description: 多阶段构建(multi-stage build) ，如可使用 `alpine` ，再 `apk add` 一些相关编译包进行编译，最后缩小镜像 。使用 Hexo 作为示例
---

# 前期准备

## 拉取hexo source/_post 的分支

> `hexo` 分支为 hexo markdown 源码分支

`git pull origin hexo`
```shell
mkdir -p ~/hexo/source
cd ~/hexo/source
git init
git pull https://github.com/yanzhe919/yanzhe919.github.io.git hexo:hexo
```

> - 顺便解释一下， `git pull origin hexo` 相当于 `git fetch origin hexo` + `git checkout -b hexo origin/hexo`

  - `cd ~/hexo` ，以下操作都在 `~/hexo` 下执行

# 以前正常使用 Dockerfile ，如 node:lts


## 编辑并创建 Dockerfile ， vim Dockerfile_lts

`vim Dockerfile_lts`
```Dockerfile
FROM node:lts as build
LABEL maintainer="yan zhe <yanzhe919@gmail.com>"
WORKDIR /hexo
VOLUME ["/hexo"]
RUN npm install hexo-cli -g
EXPOSE 4000
CMD []
```

## 构建镜像

`docker build -t hexo-blog:0.0.1 -f ~/hexo/Dockerfile_lts  .`

> 镜像大概 933MB 

## 安装插件， package.json

`docker run -it --rm -v ~/hexo/source:/hexo hexo-blog:0.0.1 sh -c "cd /hexo;npm install"`

>  有些插件可能需要从源码编译，但是 lts 版本带了很多编译工具

## 测试，生成并显示页面

`docker run -it --rm -p 80:4000 -v ~/hexo/source:/hexo hexo-blog:0.0.1 sh -c "cd /hexo;hexo generate && hexo server"`


# 正在使用的 Dockerfile ，如 node:alpine


## 编辑并创建 Dockerfile ， vim Dockerfile_alpine

`vim Dockerfile_alpine`
```Dockerfile
FROM node:lts-alpine as build
LABEL maintainer="yan zhe <yanzhe919@gmail.com>"
RUN apk update && apk upgrade && \
    apk add --no-cache git 
RUN npm add hexo-cli -g
EXPOSE 4000
CMD []
```

## 构建镜像

`docker build -t hexo-blog:0.0.3  -f ~/hexo/Dockerfile_alpine .`

> 镜像大概 123MB 

## 安装插件， package.json

`docker run -it --rm -v ~/hexo/source:/hexo hexo-blog:0.0.3 sh -c "cd /hexo;npm install"`

>  有些插件可能需要从源码编译，需要使用 `apk add` 先进行安装编译工具 ，如我正在使用的插件

`docker run -it --rm -v ~/hexo/source:/hexo hexo-blog:0.0.3 sh -c "apk add --no-cache autoconf automake build-base libtool nasm pkgconfig libjpeg-turbo;cd /hexo;npm install"`

## 测试，生成并显示页面


`docker run -d --name hexo -p 80:4000 -v ~/hexo/source:/hexo hexo-blog:0.0.3 sh -c "cd /hexo; hexo generate && hexo server"`

> 顺便使用 -d 后台运行。 

查看日志

`docker logs hexo`

删除容器

`docker rm hexo`

> 删除前如还在运行，最好是先停止 `docker stop hexo` ，当然有把握，可以 force 直接删除 `-f`

# 多阶段构建(multi-stage build) 

以上都为顺便的记录。主要是想看看 Docker 多阶段构建(multi-stage build) 。只是使用 Hexo 作为示例，但是它并不是很适合。可以直接使用 `Github Action` 工作流自动化部署。

# Multi-stage Dockerfile ，如 node:lts 编译，node:lts_slim 运行

## 编辑并创建 Dockerfile ， vim Dockerfile_lts_build

> 这里只是示例，就直接将 `package.json` 打包进镜像中了。构建镜像中安装插件

`vim Dockerfile_lts_build`
```Dockerfile
FROM node:lts as build
LABEL maintainer="yan zhe <yanzhe919@gmail.com>"
WORKDIR /hexo
ARG package=package.json
COPY $package ./
# install node-prune (https://github.com/tj/node-prune)
RUN curl -sfL https://install.goreleaser.com/github.com/tj/node-prune.sh | bash -s -- -b /usr/local/bin
#RUN yarn install --production=true
RUN npm install
# remove development dependencies
RUN npm prune --production
FROM node:lts-slim
COPY --from=build /hexo /hexo
RUN npm install hexo-cli -g
VOLUME ["/hexo"]
EXPOSE 4000
CMD []
```

> 使用 `node-prune` 本来是想进一步缩小镜像，但是实际测试中，似乎并没有，可能 Hexo Demo 不行。感兴趣的可以看下 [三步缩小Node镜像](https://medium.com/trendyol-tech/how-we-reduce-node-docker-image-size-in-3-steps-ff2762b51d5a)

## 构建镜像

`docker build --build-arg package=source/package.json -t hexo-blog:0.0.2 --no-cache -f ~/hexo/Dockerfile_lts_build .`

> `--no-cache=true` ，将中间生成的 cache 构建后删除。来自 [官方最佳实践](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#leverage-build-cache)。不过，还是建议测试 build 时候不要加上

> 如果没加，需要删除缓存 ` docker image prune -f `

> 镜像大概 330MB 

## 拷贝镜像中文件，已安装的插件

`docker run --name hexo hexo-blog:0.0.2`

`docker cp hexo:/hexo/node_modules ~/hexo/source/`

>  此时容器已停止，`docker cp` 一样可用

## 测试，生成并显示页面

`docker run -it --rm -p 80:4000 -v ~/hexo/source:/hexo hexo-blog:0.0.2 sh -c "cd /hexo;hexo generate && hexo server"`

# Multi-stage Dockerfile ，如 node:lts-alpine 编译，另一个 node:lts-alpine 运行

## 编辑并创建 Dockerfile ， vim Dockerfile_alpine_build

> 这里只是示例，就直接将 `package.json` 打包进镜像中了。构建镜像中安装插件

`vim Dockerfile_alpine_build`
```Dockerfile
FROM node:lts-alpine as build
LABEL maintainer="yan zhe <yanzhe919@gmail.com>"
WORKDIR /hexo
ARG package=package.json
COPY $package ./
RUN apk update && apk upgrade && \
	apk add --no-cache git curl && \
	apk add --no-cache autoconf automake build-base libtool nasm pkgconfig libjpeg-turbo
RUN npm add hexo-cli -g && \
	npm install --save
# install node-prune (https://github.com/tj/node-prune)
RUN curl -sfL https://install.goreleaser.com/github.com/tj/node-prune.sh | bash -s -- -b /usr/local/bin
#RUN yarn install --production=true
# remove development dependencies
RUN npm prune --production
FROM node:lts-alpine
COPY --from=build /hexo /hexo
RUN npm install hexo-cli -g
VOLUME ["/hexo"]
EXPOSE 4000
CMD []

```

> 使用 `node-prune` 本来是想进一步缩小镜像，但是实际测试中，似乎并没有，可能 Hexo Demo 不行。感兴趣的可以看下 [三步缩小Node镜像](https://medium.com/trendyol-tech/how-we-reduce-node-docker-image-size-in-3-steps-ff2762b51d5a)

## 构建镜像

`docker build --build-arg package=source/package.json -t hexo-blog:0.0.4  --no-cache  -f ~/hexo/Dockerfile_alpine_build .`

> `--no-cache=true` ，将中间生成的 cache 构建后删除。来自 [官方最佳实践](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#leverage-build-cache)。不过，还是建议测试 build 时候不要加上

> 如果没加，需要删除缓存 ` docker image prune -f `

> 镜像大概 300MB 

## 拷贝镜像中文件，已安装的插件

`docker run --name hexo hexo-blog:0.0.4`

`docker cp hexo:/hexo/node_modules ~/hexo/source/`

>  此时容器已停止，`docker cp` 一样可用

## 测试，生成并显示页面

`docker run -it --rm -p 80:4000 -v ~/hexo/source:/hexo hexo-blog:0.0.4 sh -c "cd /hexo;hexo generate && hexo server"`

# Docker Hexo 其他命令

在多阶段构建(multi-stage build)中，如果没有加 `--no-cache` ，除了`<none>` 镜像，可能还会产生一些已停止的容器

## 同时删除多个符合筛选条件的 docker 容器

如：删除已停止的容器

`docker rm $(docker container ls -f "status=exited" -q)`

## 删除所有容器

`docker rm $(docker container ls -aq)`

## Docker Hexo 新增 markdown

`docker run -it --rm -p 4000:4000 -v ~/hexo/source:/hexo hexo-blog:alpine sh -c "cd /hexo;hexo new 'use docker multi-stage build'"`

## Docker Hexo 根据 markdown 生成页面

`docker run -it --rm -p 80:4000 -v ~/hexo/source:/hexo hexo-blog:alpine sh -c "cd /hexo;hexo generate"`

## Docker Hexo 根据 markdown 清理并生成页面

`docker run -it --rm -p 4000:4000 -v ~/hexo/source:/hexo hexo-blog:alpine sh -c "cd /hexo;hexo clean && hexo generate"`

## Docker Hexo 初始化

`docker run -it --rm -p 4000:4000 -v ~/hexo/source:/hexo hexo-blog:alpine sh -c  “cd /hexo;hexo init blog”`

# Github Action 自动化构建 - Hexo

另外写一篇好了 Github Action 自动化构建 - Hexo