# 创建容器网络
echo "创建内部网络:saas:172.10.1.0/16"
docker network create --driver bridge --subnet 172.10.1.0/16 --gateway 172.10.1.0 saas
echo "saas网络已创建172.10.1.0/16"
docker network ls |grep saas


# 安装redis
echo "安装redis关联，内网网络IP,172.10.1.10"
docker run -itd --name saas-redis --network saas --ip 172.10.1.10 -p 6379:6379 redis

# 安装mysql

echo "安装mysql关联，内网网络IP,172.10.1.20，账号root，密码abcd1234"
docker run -itd --name saas-mysql --network saas --ip 172.10.1.20 -p 3306:3306 -e MYSQL_ROOT_PASSWORD=abcd1234 mysql:5.7

# 安装rabbitmq

echo "安装rabbitmq，内网网络IP，172.10.1.30"

docker run -itd --name saas-rabbitmq --network saas --ip 172.10.1.30 -p 15672:15672 -p 5672:5672  rabbitmq
echo "睡眠15秒等待 rabbitmq启动完成"
sleep 15
echo "增加vhost /saas"
docker exec -it saas-rabbitmq bash -c 'rabbitmqctl add_vhost /saas'
echo "赋予guest访问vhost权限"
docker exec -it saas-rabbitmq bash -c 'rabbitmqctl set_permissions -p /saas guest ".*" ".*" ".*"'
docker exec -it saas-rabbitmq bash -c 'rabbitmqctl list_permissions -p /saas'
echo "启动WEB UI中"
docker exec -it saas-rabbitmq bash -c 'rabbitmq-plugins enable rabbitmq_management'


# rabbitmq-plugins enable rabbitmq_delayed_message_exchange  
echo "下载rabbitmq延迟队列插件"
curl -L -O https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases/download/3.10.2/rabbitmq_delayed_message_exchange-3.10.2.ez
echo "复制rabbitmq延迟队列插件到容器"
docker cp rabbitmq_delayed_message_exchange-3.10.2.ez saas-rabbitmq:/plugins
docker exec -it saas-rabbitmq bash -c 'ls /plugins/rabbitmq_delayed_message_exchange-3.10.2.ez'
echo "启动rabbitmq延迟队列插件到容器"
docker exec -it saas-rabbitmq bash -c 'rabbitmq-plugins enable rabbitmq_delayed_message_exchange'
echo "启动延迟队列重启rabbitmq"
docker restart saas-rabbitmq

