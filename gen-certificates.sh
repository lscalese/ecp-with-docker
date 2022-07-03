#!/bin/sh

RSA_KEY_NUMBITS="2048"
DAYS="365"

GenRootCertificate() {
    local ROOT_SUBJ=$1
    local CERT_FNAME=$2
    
    echo "Generating root certificate"

    if [ ! -f "$CERT_FNAME.key" ]
    then
    # generate root certificate
    
    openssl genrsa \
        -out "$CERT_FNAME.key" \
        "$RSA_KEY_NUMBITS"

    openssl req \
        -new \
        -key "$CERT_FNAME.key" \
        -out "$CERT_FNAME.csr" \
        -subj "$ROOT_SUBJ"

    openssl req \
        -x509 \
        -key "$CERT_FNAME.key" \
        -in "$CERT_FNAME.csr" \
        -out "$CERT_FNAME.cer" \
        -days "$DAYS"

    chown -v irisowner $CERT_FNAME.cer $CERT_FNAME.key
    chgrp -v irisowner $CERT_FNAME.cer
    chgrp -v irisuser $CERT_FNAME.key
    chmod -v 644 $CERT_FNAME.cer

    else
    echo "ENTRYPOINT: ./certificates/CA_Server.key already exists"
    fi

}

GenCertificate() {
    local PUBLIC_SUBJ=$1
    local CERT_FNAME=$2
    local CERT_ROOT=${3:-./certificates/CA_server.cer}

    
    if [ ! -f "$CERT_FNAME.cer" ]
    then
    # generate public rsa key
    openssl genrsa \
        -out "$CERT_FNAME.key" \
        "$RSA_KEY_NUMBITS"
    else
    echo "ENTRYPOINT: $CERT_FNAME.cer already exists"
    return
    fi

    if [ ! -f "$CERT_FNAME.cer" ]
    then
    # generate public certificate
    
    openssl req \
        -new \
        -key "$CERT_FNAME.key" \
        -out "$CERT_FNAME.csr" \
        -subj "$PUBLIC_SUBJ"

    openssl x509 \
        -req \
        -in "$CERT_FNAME.csr" \
        -CA "$CERT_ROOT.cer" \
        -CAkey "$CERT_ROOT.key" \
        -out "$CERT_FNAME.cer" \
        -CAcreateserial \
        -days "$DAYS"
    
    cat $CERT_ROOT.cer >> "$CERT_FNAME.cer"
    else
    echo "ENTRYPOINT: $CERT_FNAME.cer already exists"
    fi
}

GenIrisInstanceCertificate() {
    local PUBLIC_SUBJ=$1
    local CERT_FNAME=$2
    local CERT_ROOT=${3:-./certificates/CA_server.cer}

    GenCertificate $PUBLIC_SUBJ $CERT_FNAME $CERT_ROOT
    rm -vfr $CERT_FNAME.csr
    chown irisowner $CERT_FNAME.key $CERT_FNAME.cer
    chgrp irisowner $CERT_FNAME.cer 
    chgrp irisuser $CERT_FNAME.key
    chmod 644 $CERT_FNAME.cer
    chmod 640 $CERT_FNAME.key
}

rm -vfr certificates

mkdir -p ./certificates
GenRootCertificate "/C=BE/ST=Wallonia/L=Namur/O=Community/OU=IT/CN=testroot" "./certificates/CA_Server"
rm -vfr ./certificates/CA_Server.csr

# GenCertificate Arguments : 
#  1. subject
#  2. Certificate filename
#  3. Root Certificate filename

# Generate IRIS application server certificate
GenIrisInstanceCertificate "/C=BE/ST=Wallonia/L=Namur/O=Community/OU=IT/CN=master" "./certificates/app_server" "./certificates/CA_Server"

# Generate IRIS data server certificate
GenIrisInstanceCertificate "/C=BE/ST=Wallonia/L=Namur/O=Community/OU=IT/CN=report" "./certificates/data_server" "./certificates/CA_Server"