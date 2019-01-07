# Certificate Signing Request
#
# Country Name (2 letter code) []:
# State or Province Name (full name) []:
# Locality Name (eg, city) []:
# Organization Name (eg, company) []:
# Organizational Unit Name (eg, section) [Domain Control Validated]:
# Secondary Organizational Unit Name (eg, section) [InternalSSL]:
# Common Name (eg, your name or your server's hostname) []:
# Email Address []:
echo -n -e "\n\n\n\n\n\nwww.domain.com\n\n" | openssl req -config openssl.cnf -sha256 -new -key private/www.domain.com.key -out certs/www.domain.com.csr
echo -n -e "\n\n\n\n\n\n*.domain.com\n\n" | openssl req -config openssl.cnf -sha256 -new -key private/wildcard.domain.com.key -out certs/wildcard.domain.com.csr


# Sign CSR
openssl ca -config openssl.cnf -passin file:password -md sha256 -in certs/www.domain.com.csr -out certs/www.domain.com.pem -extfile domain.com.cnf 

# extfile content
authorityKeyIdentifier=keyid,issuer
subjectKeyIdentifier=hash
keyUsage = critical, digitalSignature, keyEncipherment
basicConstraints = critical, CA:FALSE
extendedKeyUsage = serverAuth, clientAuth
certificatePolicies = 2.23.140.1.2.1
crlDistributionPoints = URI:http://crl.companyca.com/CompanyRSADomainValidationSecureServerCA.crl
authorityInfoAccess = caIssuers;URI:http://crt.companyca.com/CompanyRSADomainValidationSecureServerCA.crt, OCSP;URI:http://ocsp.companyca.com
subjectAltName = @subject_alt_section

[ subject_alt_section ]
DNS.1 = domain.com
