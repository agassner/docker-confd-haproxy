DOCKER_IMAGE=docker-confd-haproxy

rm:
	-docker rm -f ${DOCKER_IMAGE}

build:
	docker build -t ${DOCKER_IMAGE} .

run: build
	docker run -d -p 8000:8000 -p 8001:8001 --name ${DOCKER_IMAGE} ${DOCKER_IMAGE} -node $$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' etcd):4001

run-etcd:
	docker run -d -p 4001:4001 -p 7001:7001 --name etcd quay.io/coreos/etcd \
		-listen-client-urls http://0.0.0.0:4001 \
    	-advertise-client-urls http://localhost:4001

run-app:
	# An example of simple app https://github.com/agassner/docker-node
	docker run -d -e SERVICE_NAME=simple-app -h $$(docker-machine ip) --name app1 -p 8081:8080 simple-app
	docker run -d -e SERVICE_NAME=simple-app -h $$(docker-machine ip) --name app2 -p 8082:8080 simple-app

run-app3:
	docker run -d -e SERVICE_NAME=simple-app -h $$(docker-machine ip) --name app3 -p 8083:8080 simple-app

run-dependencies: run-etcd run-app

clean-up: rm clean-up-app
	-docker rm -f etcd

clean-up-app:
	-docker rm -f app1 app2 app3
