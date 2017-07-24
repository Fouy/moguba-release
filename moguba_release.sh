#!/bin/bash
# author: xuefeihu

# 项目目录
moguhuPath="/root/project"
convertMoguhuPath=${moguhuPath//\//\\\/} #将${moguhuPath}变为转义串

gitMoguhuPath="/Users/xuefeihu/hugege/code-sublime"
convertGitMoguhuPath=${gitMoguhuPath//\//\\\/}

projectPath=${moguhuPath}"/moguba"
convertProjectPath=${projectPath//\//\\\/} #将${projectPath}变为转义串

gitProjectPath=${gitMoguhuPath}"/moguba"
convertGitProjectPath=${gitProjectPath//\//\\\/}

# openresty 安装目录
openrestyPath="/root/software/openresty"
convertOpenrestyPath=${openrestyPath//\//\\\/}

gitOpenrestyPath="/Users/xuefeihu/software/openresty"
convertGitOpenrestyPath=${gitOpenrestyPath//\//\\\/}

# github地址
projectUrl="https://codeload.github.com/Fouy/moguba-release/zip/master"

# stop server
sudo ${openrestyPath}/nginx/sbin/nginx -c ${projectPath}/config/nginx.conf -p ${projectPath} -s stop
echo "OpenResty stoped"
echo -e "########################################################################\n\n"

# remove old project path
if [ -d "$projectPath" ]; then
	sudo rm -rf ${projectPath}
fi

# get source code and publish
sudo wget ${projectUrl} -O ${moguhuPath}/moguba-release-master.zip
sudo unzip ${moguhuPath}/moguba-release-master.zip -d ${moguhuPath}
sudo mv ${moguhuPath}/moguba-release-master ${projectPath}
sudo rm -rf ${moguhuPath}/moguba-release-master.zip

# replace /bin/* files
sudo sed -i 's/'${convertGitProjectPath}'/'${convertProjectPath}'/g' ${projectPath}/bin/*
sudo sed -i 's/'${convertGitOpenrestyPath}'/'${convertOpenrestyPath}'/g' ${projectPath}/bin/*

# replace config/* files
sudo sed -i 's/'${convertGitProjectPath}'/'${convertProjectPath}'/g' ${projectPath}/config/*
sudo sed -i 's/'${convertGitMoguhuPath}'/'${convertMoguhuPath}'/g' ${projectPath}/config/*
sudo sed -i 's/'${convertGitOpenrestyPath}'/'${convertOpenrestyPath}'/g' ${projectPath}/config/*

sudo sed -i 's/#user  nobody;/user  root;/g' ${projectPath}/config/nginx.conf
sudo sed -i 's/lua_code_cache off;/lua_code_cache on;/g' ${projectPath}/config/nginx.conf

# replace lua/* files
sudo sed -i 's/'${convertGitProjectPath}'/'${convertProjectPath}'/g' ${projectPath}/lua/init.lua

sudo chmod a+x ${projectPath}/*

# start server
sudo ${openrestyPath}/nginx/sbin/nginx -c ${projectPath}/config/nginx.conf -p ${projectPath}
echo "OpenResty start"
echo -e "########################################################################\n\n"
tail -f ${projectPath}/logs/error.log

