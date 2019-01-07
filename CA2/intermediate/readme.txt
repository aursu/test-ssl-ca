# IM CA setup
mkdir -p intermediate/{private,certs,newcerts,crl}

:> intermediate/index.txt
echo -n 'unique_subject = no' > intermediate/index.txt.attr
echo -n '01' > intermediate/serial
echo -n '01' > intermediate/crlnumber

# setup intermediate/openssl.cnf

# setup intermediate/password file

# generate intermediate CA private key
openssl genrsa -des3 -out intermediate/private/cakey.pem -passout file:intermediate/password  2048

# create signing request for intermediate CA
echo -n -e "DE\nHessen\nFrankfurt\nCompany CA Limited\n\nCompany RSA Domain Validation Secure Server CA\n\n" |
    openssl req -config openssl.cnf -sha256 -new -key intermediate/private/cakey.pem -passin file:intermediate/password -out intermediate/certs/cacsr.pem

# create intermediate CA certificate
openssl ca -config openssl.cnf -passin file:password -extensions v3_ca_intermediate -md sha256 -in intermediate/certs/cacsr.pem -out intermediate/cacert.pem
