#!/bin/bash

# 启动PostgreSQL
mkdir -p /var/run/postgresql
chown postgres:postgres /var/run/postgresql
su - postgres -c "/usr/lib/postgresql/*/bin/pg_ctl -D /var/lib/postgresql/*/main -l /var/log/postgresql/postgresql.log start"
su - postgres -c "createuser -s root" || true
su - postgres -c "createdb root" || true

# 启动Redis
redis-server /etc/redis/redis.conf --daemonize yes

# 启动SSH服务
/usr/sbin/sshd

# 保持容器运行
exec tail -f /dev/null