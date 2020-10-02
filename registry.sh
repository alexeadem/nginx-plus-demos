#!/bin/bash -x


k8s_ingress_repo=../kubernetes-ingress/
ip=localhost
registry=$ip:5000

n=alpine
t=3.10.4


kubernetes_ingress() {

    if [ ! -d  ../kubernetes-ingress/ ]; then
        cd ..
        git clone https://github.com/nginxinc/kubernetes-ingress.git
        cd kubernetes-ingress
        git checkout  tags/v1.7.2
        cd ../att
    fi

}



usage()
{

    kubernetes_ingress

    v=$(docker run -it alpine:3.10.4 apk search nginx | grep '^nginx-plus-[0-9]' | cut -d'-' -f3-4)
    v=${v//[$'\t\r']/}
    v=${v//[$'\n']/ | }
    cd $k8s_ingress_repo
    t=`git describe --tags`
    cd - > /dev/null

    i=`curl --silent -X GET localhost:5000/v2/_catalog | awk -F'[][]' '{print $2}'`
    i=${i//\"/}
    i=${i//\,/ | }

    vs=`./ngxscan/docker/ngxscan_x86-64 version`
    
    echo -e "\033[34m Usage: \033[0m"  
    echo "$0 [ -h | --help   ]"
    echo "$0 [ -b | --build  ] [ nginx-plus ] [ $v ]"
    echo "$0 [ -b | --build  ] [ nginx-plus-ingress ] [ $t ]"
    echo "$0 [ -b | --build  ] [ ngxscan ] [ $vs ]"
    echo "$0 [ -l | --list   ] [ available ]"

    if [ ! -z "$i" ]; then 
        echo "$0 [ -r | --run    ] [ $i ]"
        echo "$0 [ -d | --delete ] [ $i ]"
    fi
    echo "$0 [ -c | --license ]"

    exit 0;
       
}

delete()
{

    registry="$ip:5000"
    echo $registry
    name=$1


    if [ -z $name ]; then
        usage
    fi

    



    curl -v -sSL -X DELETE "http://${registry}/v2/${name}/manifests/$(
        curl -sSL -I \
            -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
            "http://${registry}/v2/${name}/manifests/$(
                curl -sSL "http://${registry}/v2/${name}/tags/list" | jq -r '.tags[0]'
            )" \
        | awk '$1 == "Docker-Content-Digest:" { print $2 }' \
        | tr -d $'\r' \
    )"

  


}



list() {



    if [ "$1" = "available" ]; then   

        echo "nginx-plus:"
        v=`docker run -it  alpine:3.10.4 apk search nginx | grep '^nginx-plus-[0-9]' | cut -d'-' -f3-4`
        echo -e "\033[32m$v\033[0m" 
        echo "nginx-plus-ingress:"
        cd $k8s_ingress_repo
        v=`git describe --tags`
        echo -e "\033[32m$v\033[0m"  
        cd - > /dev/null
        echo "ngxscan:"
        v=`./ngxscan/docker/ngxscan_x86-64 version`
        echo -e "\033[32m$v\033[0m"

    else
        curl --silent -X GET $ip:5000/v2/_catalog
        images=`curl --silent -X GET localhost:5000/v2/_catalog | awk -F'[][]' '{print $2}'`
     
        IFS=','
        for i in $images
        do
            image=`curl --silent -X GET localhost:5000/v2/${i//[$'"']}/tags/list`
            image=${image//null/ '\033[31m' -- deleted -- '\033[0m' }
            echo $image
        done
 
    fi



 
    exit 0
}

build() {


    if [ -z $2 ]; then
        usage
    fi

    if [ $1 = "nginx-plus" ]; then

        cp licenses/nginx-repo.* nginx-plus/etc/ssl/

        f=0;
        for i in $(docker run -it alpine:3.10.4 apk search nginx | grep '^nginx-plus-[0-9]' | cut -d'-' -f3-4)
        do

            if [ ${i//[$'\t\r\n']} == "$2" ]; then
                cd ~/nginx
                docker build -t nginx-plus:$2 --build-arg version=$2 -f nginx-plus/Dockerfile .
                docker tag $1:$2 $ip:5000/$1:$2
                docker push $ip:5000/$1:$2
                f=1
                break
            fi
        done

        if [ $f = 0 ]; then 
            usage 
        fi

    elif [ $1 = "nginx-plus-ingress" ]; then

        kubernetes_ingress
        
        cp licenses/nginx-repo.* $k8s_ingress_repo
        
        cd $k8s_ingress_repo
        p=`git describe --tags`
        
        if [ $p = "$2" ]; then
            make clean && make DOCKERFILE=DockerfileForPlus VERSION=$2 PREFIX=$ip:5000/nginx-plus-ingress
        else
            usage
        fi

    elif [ $1 = "ngxscan" ]; then
        cp licenses/nginx-repo.* ngxscan/
        v=`./ngxscan/docker/ngxscan_x86-64 version`
        
        cd ngxscan
        docker build --build-arg USER=$(whoami) --build-arg UID=$(id -u) -t $1:$v -f  docker/Dockerfile .
        docker tag $1:$v $ip:5000/$1:$v
        docker push $ip:5000/$1:$v    
        
    fi
 


    exit 0
}

license() {

    cd licenses
    ./validate-licenses.sh
}

run() {

    if [ -z $1 ]; then
        usage
    fi

    if [ $1 = "nginx-plus-ingress" ]; then
        kubectl create namespace nginx-ingress
        DIR=nginx-plus-ingress/k8s
        kubectl apply -f $DIR/deployments/rbac/rbac.yaml
        kubectl apply -f $DIR/deployments/common/ns-and-sa.yaml
        kubectl apply -f $DIR/deployments/common/nginx-config.yaml
        kubectl apply -f $DIR/deployments/common/ts-definition.yaml
        kubectl apply -f $DIR/deployments/common/vs-definition.yaml
        kubectl apply -f $DIR/deployments/common/vsr-definition.yaml
        kubectl apply -f $DIR/deployments/common/default-server-secret.yaml
        #
        kubectl apply -f $DIR/deployments/deployment/nginx-plus-ingress.yaml
        # 
        kubectl apply -f $DIR/tcp-udp/nginx-plus-config.yaml
    elif [ $1 = "nginx-plus" ]; then
        echo "nginx-plus"
        kubectl apply -f nginx-plus/k8s
        #i=`curl --silent -X GET localhost:5000/v2/_catalog | awk -F'[][]' '{print $2}'`
        #docker run localhost:5000/nginx-plus:$i
    elif [ $1 = "ngxscan" ]; then
        echo "ngxscan"
        kubectl apply -f ngxscan/ngxscan.yaml
        ngxscan/run.sh
    else
        usage
    fi

    exit 0
}


if [[ "$(docker images -q $n:$t 2> /dev/null)" == "" ]]; then
        docker build -t alpine:3.10.4 -f docker/alpine/3.10.4/Dockerfile .
fi

while true; do
    case "$1" in
        ### BEGIN ###
        -b | --build )
        case "$2" in
            nginx-plus ) 
            build $2 $3
            break;;
            nginx-plus-ingress ) 
            build $2 $3
            break;;
            ngxscan ) 
            build $2 $3
            break;;
            *) usage
            break;;
        esac 
        break;;
        ### END ###
        ### BEGIN ###
        -l | --list )
        case "$2" in
            version ) list $2
            break;;
            *) list $2
            break;;
        esac  
        break;;
        ### END ###
        -r | --run )
            run $2  
            break;;
        -d | --delete )
            delete $2 
            break;;
        -c | --license )
            license
            break;;
        -h | --help ) 
            usage; 
            break;;
        --) 
            break;;
        *) 
            usage 
            break;;
    esac
done


exit 0



