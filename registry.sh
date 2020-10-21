#!/bin/bash 


ip=localhost
registry=$ip:5000



usage()
{


    
    echo -e "\033[34m Usage: \033[0m"  
    echo "$0 [ -h | --help   ]"
    echo "$0 [ -l | --list   ]"
    echo "$0 [ -l | --delete  ]"
    echo "$0 [ -c | --license ]"

    exit 0;
       
}

delete()
{

    registry="$ip:5000"
    echo $registry
    name=$1

echo $name

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

    # REG_POD=`kubectl get pods -n kube-system -lactual-registry=true --no-headers | awk '{print $1}'`
    # kubectl exec $REG_POD -n kube-system -- rm -rf /var/lib/registry/docker/registry/v2/repositories/$name
    # kubectl exec $REG_POD -n kube-system -- bin/registry garbage-collect /etc/docker/registry/config.yml




}


list() {


    curl --silent -X GET $ip:5000/v2/_catalog
    images=`curl --silent -X GET localhost:5000/v2/_catalog | awk -F'[][]' '{print $2}'`
    
    IFS=','
    for i in $images
    do
        image=`curl --silent -X GET localhost:5000/v2/${i//[$'"']}/tags/list`
        image=${image//null/ '\033[31m' -- deleted -- '\033[0m' }
        echo $image
    done
 

    exit 0
}


while true; do
    case "$1" in
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



