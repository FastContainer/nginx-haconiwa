default: build_all

dispatcher:
	docker build -t nginx-haconiwa ./nginx
	docker run --rm -v $(PWD)/nginx/builds:/builds -t nginx-haconiwa
	mv ./nginx/builds/nginx* ./provision/dist/

base:
	docker build -t haconiwa-container:base ./container/base

nginx:
	docker build -t haconiwa-container:nginx ./container/nginx
	docker run -d -h nginx --rm --name haconiwa-nginx -t haconiwa-container:nginx
	docker export haconiwa-nginx > ./provision/dist/nginx.image.tar
	docker stop haconiwa-nginx
	docker rmi haconiwa-container:nginx

ssh:
	docker build -t haconiwa-container:ssh ./container/ssh
	docker run -d -h ssh --rm --name haconiwa-ssh -t haconiwa-container:ssh
	docker export haconiwa-ssh > ./provision/dist/ssh.image.tar
	docker stop haconiwa-ssh
	docker rmi haconiwa-container:ssh

postfix:
	docker build -t haconiwa-container:postfix ./container/postfix
	docker run -d -h postfix --rm --name haconiwa-postfix -t haconiwa-container:postfix
	docker export haconiwa-postfix > ./provision/dist/postfix.image.tar
	docker stop haconiwa-postfix
	docker rmi haconiwa-container:postfix

build: base nginx ssh postfix
build_all: dispatcher build

.PHONY: dispatcher
