echo "删除mysql"
docker rm -f saas-mysql
echo "删除rabbitmq"
docker rm -f saas-rabbitmq
echo "删除redis"
docker rm -f saas-redis
echo "删除nacos"
docker rm -f saas-nacos

echo "删除es"
docker rm -f saas-elasticsearch
docker rm -f saas-kibana

echo "依然存在的容器有："
docker ps -a |grep saas

echo "删除网络"
docker network rm saas
docker network ls |grep saas