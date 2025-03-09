FROM python:3.12

# 更新APT并安装基础包
RUN apt-get clean && \
    apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    procps git curl openssh-server gnupg2 lsb-release wget \
    build-essential libpq-dev

# 设置PostgreSQL
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql postgresql-contrib

# 安装Redis
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y redis-server && \
    sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf

# 安装Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs && \
    npm install -g npm@8

# 设置SSH
RUN mkdir -p /run/sshd && \
    echo 'root:jkjjjkjjk' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# 配置pip
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/

# 创建数据目录
RUN mkdir -p /app/data && \
    chown -R root:root /app/data

# 设置启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 22 80 3000 5001 8000

CMD ["/start.sh"]
