FROM python:3.12

# 配置DNS
RUN echo "nameserver 223.5.5.5" > /etc/resolv.conf && \
    echo "nameserver 223.6.6.6" >> /etc/resolv.conf

# 设置APT
RUN mkdir -p /etc/apt/sources.list.d && \
    rm -f /etc/apt/sources.list.d/* || true && \
    rm -f /var/lib/apt/lists/lock || true && \
    rm -f /var/cache/apt/archives/lock || true && \
    rm -f /var/lib/dpkg/lock* || true

# 配置APT源
RUN echo "deb http://mirrors.aliyun.com/debian/ bookworm main non-free non-free-firmware contrib" > /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian/ bookworm-updates main non-free non-free-firmware contrib" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian-security bookworm-security main non-free non-free-firmware contrib" >> /etc/apt/sources.list

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
