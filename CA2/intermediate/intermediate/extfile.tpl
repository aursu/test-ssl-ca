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
