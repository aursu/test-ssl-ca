# CA setup
mkdir -p private certs newcerts crl

:> index.txt
echo -n 'unique_subject = no' > index.txt.attr
echo -n '01' > serial
echo -n '01' > crlnumber

# setup openssl.cnf

# setup password file

# create root CA key
openssl genrsa -des3 -passout file:password -out private/cakey.pem 2048

# create root CA certificate
echo -n -e "DE\n\n\nDomainDotCom AB\nDomainDotCom External TTP Network\nDomainDotCom External CA Root\n\n" |
    openssl req -new -x509 -days 3650 -config openssl.cnf -key private/cakey.pem -sha256 -extensions v3_ca -passin file:password -set_serial 1  -out cacert.pem

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
echo -n -e "DE\nHessen\nFrankfurt\nCompany CA Limited\n\nCompany RSA Certification Authority\n\n" |
    openssl req -config openssl.cnf -sha256 -new -key intermediate/private/cakey.pem -passin file:intermediate/password -out intermediate/certs/cacsr.pem

# create intermediate CA certificate
openssl ca -config openssl.cnf -passin file:password -extensions v3_ca_intermediate -md sha256 -in intermediate/certs/cacsr.pem -out intermediate/cacert.pem

