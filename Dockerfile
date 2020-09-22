FROM centos:7
MAINTAINER V7hinc

ENV WOOYUN_DB="wooyun"
ENV DB_Root_Password="wooyun"

VOLUME ["/data/www/default/images"]

RUN yum -y install wget git \
    && cd /tmp \

    # 安装lamp
    && wget http://soft.vpser.net/lnmp/lnmp1.7.tar.gz -cO lnmp1.7.tar.gz \
    && tar zxf lnmp1.7.tar.gz && cd lnmp1.7 \
    # lnmp脚本无人值守命令解释：DBSelect="4"表示MySQL5.7、PHPSelect="5"表示PHP5.6、SelectMalloc="1"表示不安装内存分配器、ApacheSelect="1"表示Apache2.2，其他请查看https://lnmp.org/faq/v1-5-auto-install.html
    && LNMP_Auto="y" DBSelect="4" DB_Root_Password="${DB_Root_Password}" InstallInnodb="y" PHPSelect="5" SelectMalloc="1" ApacheSelect="1" ServerAdmin=" CheckMirror="n"" ./install.sh lamp \
    && cd /home/wwwroot/default \
    # 清除网站根目录下的默认数据
    && rm -rf * \
    # 拉取网站源码到当前目录
    && git clone https://github.com/V7hinc/wooyun_final.git ./ \
    # 删除Dockerfile文件
    && rm -rf Dockerfile \
    # 替换数据库密码
    && sed -i "s/root\")/${DB_Root_Password}\")/" conn.php \
    # 创建数据库wooyun
    && create_db_sql="create database IF NOT EXISTS ${WOOYUN_DB}" \
    && mysql -hlocalhost -P3306 -uroot -p${DB_Root_Password} -e "${create_db_sql}" \
    # 下载数据库源文件
    && wget -c https://github.com/V7hinc/wooyun_final/releases/download/1.0/wooyun_bugs_db.tar.bz2 \
    # 解压数据库源文件到wooyun数据库目录下
    && tar xjvf wooyun_bugs_db.tar.bz2 -C /usr/local/mysql/var/${WOOYUN_DB} \
    # 清除压缩包
    && rm -rf wooyun_bugs_db.tar.bz2


EXPOSE 80
CMD ["lnmp start"]
