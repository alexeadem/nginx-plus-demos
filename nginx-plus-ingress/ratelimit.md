location /service  {

}


limit_req_zone $binary_remote_addr zone_post=ip:10m rate=5r/s;

limit_req_zone $binary_remote_addr zone_get=ip:10m rate=100r/s;

server {
    listen 80;
    location / {

        if ($request_method = POST ) {
           limit_req zone=ip burst=12 delay=8;       
         }

        if ($request_method = GET ) {
            limit_req zone_get=ip burst=12 delay=8; 
        }
        proxy_pass http://website;
    }
}

# https://www.nginx.com/blog/rate-limiting-nginx/


