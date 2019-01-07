# CA setup (Draft version)
cd CA
:> index.txt
echo -n 'unique_subject = no' > index.txt.attr
echo '01' > serial

openssl genrsa -des3 -passout file:password -out private/cakey.pem 2048
chmod 400 private/cakey.pem

echo -n -e "DE\n\n\nDomainDotCom AB\nDomainDotCom External TTP Network\nDomainDotCom External CA Root\n\n" | openssl req -new -x509 -days 3650 -config openssl.cnf -key private/cakey.pem -sha256 -extensions v3_ca -passin file:password -set_serial 1  -out cacert.pem

# CRL
echo '01' > crlnumber
openssl ca  -config openssl.cnf -passin file:password -gencrl -out crl.pem


####
# revoked old IM CA
openssl ca -keyfile private/cakey.pem -cert cacert.pem -revoke intermediate/cacert.pem
openssl ca -keyfile private/cakey.pem -cert cacert.pem -gencrl -out crl.pem
openssl crl -in crl.pem -outform DER -out /var/www/html/crls/ghglobal.crl
# check it
openssl ocsp -issuer /etc/pki/CA/cacert.pem -cert /etc/pki/CA/intermediate/cacert.pem -resp_text -url http://localhost:2560
####

# OCSP CSR
openssl genrsa -out /etc/ocspd/private/ocspd_key.pem 2048
echo -n -e "US\nIllinois\nChicago\nCacheNetworks LLC\n\nocsp.gamehack.com\n\n" |
    openssl req -sha256 -new -key /etc/ocspd/private/ocspd_key.pem -out /etc/ocspd/private/ocspd_csr.pem

# OCSP CRT
openssl ca -keyfile private/cakey.pem -cert cacert.pem -extensions ocsp_cert -md sha256 -in /etc/ocspd/private/ocspd_csr.pem -passin file:/etc/pki/CA/password -out /etc/ocspd/certs/ocspd_cert.pem

# check OCSP on localhost
openssl ocsp -issuer /etc/pki/CA/cacert.pem -cert /etc/pki/CA/intermediate/certs/cacert.1.pem -resp_text -url http://localhost:2560

# IM CA
mkdir -p intermediate/{private,certs,newcerts}
cp -a /etc/pki/tls/openssl.cnf /etc/pki/CA/intermediate

cd intermediate
:> index.txt
echo -n '01' > crlnumber
echo -n '01' > serial

# IM CSR
openssl genrsa -des3 -out private/cakey.pem -passout file:password  2048
echo -n -e "DE\nHessen\nFrankfurt\nCompany CA Limited\n\nCompany RSA Certification Authority\n\n" |
    openssl req -config openssl.cnf -sha256 -new -key private/cakey.pem -passin file:password -out certs/cacsr.pem

# sign IM CA with root cert
cd /etc/pki/CA
openssl ca -keyfile private/cakey.pem -passin file:/etc/pki/CA/password -cert cacert.pem -extensions v3_ca_intermediate -md sha256 -in intermediate/certs/cacsr.pem -out intermediate/cacert.pem
# we will use URL http://ghssl-aia.gamehack.com/ghssl.crt
openssl x509  -in intermediate/cacert.pem -outform DER -out /var/www/html/ghssl.crt

# IM CRL
cd /etc/pki/CA/intermediate
openssl ca -config openssl.cnf -keyfile private/cakey.pem -passin file:/etc/pki/CA/intermediate/password -cert cacert.pem -gencrl -out crl.pem

# we will have URL http://ghssl-crl.gamehack.com/crls/ghssl.crl
mkdir -p /var/www/html/crls
openssl crl -in crl.pem -outform DER -out /var/www/html/crls/ghssl.crl

####
openssl ca -config openssl.cnf -keyfile private/cakey.pem -cert cacert.pem -revoke /etc/ocspd/certs/ocspd_cert2.pem
####

# IM OCSP
openssl genrsa -out /etc/ocspd/private/ocspd_key2.pem 2048
echo -n -e "US\nIllinois\nChicago\nCacheNetworks LLC\n\nocsp.gamehack.com\n\n" |
    openssl req -config openssl.cnf -sha256 -new -key /etc/ocspd/private/ocspd_key2.pem -out /etc/ocspd/private/ocspd_csr2.pem
openssl ca -config openssl.cnf -keyfile private/cakey.pem -passin file:password -cert cacert.pem -extensions ocsp_cert -md sha256 -in /etc/ocspd/private/ocspd_csr2.pem -out /etc/ocspd/certs/ocspd_cert2.pem

# user certs (example: *.sn.eamobile.com)
cd /etc/pki/CA/intermediate
openssl genrsa -out private/wildcard.facebook.com.key 2048
echo -n -e "US\nCA\nMenlo Park\nFacebook, Inc.\n\n*.facebook.com\n\n" |
    openssl req -config openssl.cnf -sha256 -new -key private/wildcard.facebook.com.key -out certs/wildcard.facebook.com.csr
openssl ca -config openssl.cnf -keyfile private/cakey.pem -cert cacert.pem -extensions usr_cert -md sha256 -in certs/wildcard.sn.eamobile.com.csr -out certs/wildcard.sn.eamobile.com.pem

####
openssl ca -config openssl.cnf -keyfile private/cakey.pem -cert cacert.pem -revoke certs/wildcard.sn.eamobile.com.pem
openssl ca -config openssl.cnf -keyfile private/cakey.pem -passin file:password -cert cacert.pem -revoke /etc/ocspd/certs/ocspd_cert2.pem
####

Notes:
http://tools.ietf.org/html/rfc3647

