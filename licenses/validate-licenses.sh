crt=nginx-repo.crt
key=nginx-repo.key
DAYS=15

# Check that cert will not expire in the next $DAYS 
openssl x509 -in $crt -checkend $(( 24*3600*$DAYS )) -noout
if [ $? -eq 0 ]; then
  echo "in the next $DAYS days" 
  echo -e "Certifcate expiration [ \033[32mOK\033[0m ]" 
  openssl x509 -in $crt -noout -dates -subject
else
  echo -e "Certifcate expiration [ \033[31mFAILED\033[0m ]" 
  openssl x509 -in $crt -noout -dates -subject
fi

# Verify that the private key and public key are a key pair that match

key_mod=`openssl rsa -noout -modulus -in $key`
crt_mod=`openssl x509 -noout -modulus -in $crt`

if [ $key_mod = $crt_mod ]; then
  echo -e "Certificate pair match [ \033[32mOK\033[0m ]"
else
  echo -e "Certificate pair match [ \033[31mFAILED\033[0m ]"
fi





