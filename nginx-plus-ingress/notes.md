# 1

NGINX_REPO_CRT

whoami

cd ~/nginx-plus-docker-base

docker run --name test -d -p 9000:80 -p 9080:8080 -v $PWD/etc/nginx:/etc/nginx \
registry.gitlab.f5demolab.com/f5-demo-lab/nginx-plus-dockerfiles:alpine3.10

docker ps

curl http://127.0.0.1:9000 -L

docker rm test -f

# 2

exit

cd ~/Documents/Git/gitlabappster
ls
sed -i 's/app that you can trust on/app that you can trust xxx!/g' etc/nginx/html/index.html

git add .
git commit -m "Update subheader"
git push origin master

# 3

ssh centos@10.1.1.11

echo "GET http://10.1.1.11" | vegeta attack -rate=1000/s -duration=1s | vegeta report

sudo vim /etc/nginx/conf.d/www.appster.com.conf

sudo nginx -t && sudo nginx -s reload


https://docs.projectcalico.org/getting-started/clis/calicoctl/install

https://devcentral.f5.com/s/articles/CIS-and-Kubernetes-Part-1-Install-Kubernetes-and-Calico









