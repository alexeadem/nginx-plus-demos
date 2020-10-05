(set -x; curl 'http://nginx.local/web-services/user-data/1.1/auto-get-profiles-timestamp' -H 'CCRT-Subject: C=DE, O=Daimler AG, OU=MBIIS-CERT')
printf '\n'
(set -x; curl 'http://nginx.local/web-services/user-data/1.1/auto-get-profiles-timestamp' -H 'CCRT-Subject: C=DE, O=Daimler AG, OU=MBIIS-CERT, CN=WDF44770')
