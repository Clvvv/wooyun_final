FROM centos:7
MAINTAINER V7hinc

ENV WOOYUN_DB="wooyun"
ENV DB_Root_Password="wooyun"
ENV SITE_ROOT /usr/share/nginx/html

# lnmp环境搭建
RUN set -x;\
yum -y install wget git;\
cd /tmp;\
# 安装lamp
wget http://soft.vpser.net/lnmp/lnmp1.7.tar.gz -cO lnmp1.7.tar.gz;\
tar zxf lnmp1.7.tar.gz && cd lnmp1.7;\
# lnmp脚本无人值守命令解释：DBSelect="6"表示MariaDB 5.5、PHPSelect="5"表示PHP5.6、SelectMalloc="1"表示不安装内存分配器、ApacheSelect="1"表示Apache2.2，其他请查看https://lnmp.org/faq/v1-5-auto-install.html
LNMP_Auto="y" DBSelect="6" DB_Root_Password="${DB_Root_Password}" InstallInnodb="y" PHPSelect="5" SelectMalloc="1" ApacheSelect="1" ServerAdmin="" ./install.sh lamp;

# 进入网站根目录
WORKDIR ${SITE_ROOT}

# 网站源码拉取
RUN set -x;\
# 清除网站根目录下的默认数据
rm -rf *;\
# 拉取网站源码到当前目录
git clone https://github.com/V7hinc/wooyun_final.git ./;\
# 删除Dockerfile文件
rm -rf Dockerfile;\
# 替换数据库密码
sed -i "s/root\")/${DB_Root_Password}\")/" conn.php;
# wooyun数据库恢复
RUN set -x;\
# 创建数据库wooyun
create_db_sql="create database IF NOT EXISTS ${WOOYUN_DB}";\
mysql -hlocalhost -P3306 -uroot -p${DB_Root_Password} -e "${create_db_sql}";\
# 下载数据库源文件
echo "正在下载wooyun_bugs_db.tar.bz2文件";\
wget -c https://github.com/V7hinc/wooyun_final/releases/download/1.0/wooyun_bugs_db.tar.bz2;\
# 解压数据库源文件到wooyun数据库目录下
tar xjvf wooyun_bugs_db.tar.bz2 -C /usr/local/mariadb/var/${WOOYUN_DB};\
# 清除压缩包
rm -rf wooyun_bugs_db.tar.bz2;

# 编写开机启动脚本
RUN set -x;\
echo "#!/bin/bash" >> /autostart.sh;\
# nginx 重启
echo "lnmp restart;" >> /autostart.sh;\
# 保持前台
echo "/bin/bash;" >> /autostart.sh;\
chmod 755 /autostart.sh;

VOLUME ["${SITE_ROOT}/upload"]

EXPOSE 80
EXPOSE 3306

# 切换进入docker容器默认路径为网站根目录
WORKDIR ${SITE_ROOT}

ENTRYPOINT ["/autostart.sh"]