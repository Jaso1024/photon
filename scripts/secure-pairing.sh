#!/bin/bash
# Secure pairing script for Photon containers
# This script generates certificates and configures secure communication

set -euo pipefail

CERT_DIR="/photon/certs"
DAYS_VALID=365

# Create certificate directory
mkdir -p "$CERT_DIR"

# Generate CA certificate
echo "Generating Photon CA certificate..."
openssl req -x509 -newkey rsa:4096 -days $DAYS_VALID -nodes \
    -keyout "$CERT_DIR/photon-ca.key" \
    -out "$CERT_DIR/photon-ca.crt" \
    -subj "/CN=Photon Root CA/O=Photon/C=US" \
    2>/dev/null

# Generate server certificate for each Sunshine instance
for i in {1..3}; do
    echo "Generating certificate for PC$i..."
    
    # Generate private key
    openssl genrsa -out "$CERT_DIR/pc$i.key" 4096 2>/dev/null
    
    # Generate certificate request
    openssl req -new -key "$CERT_DIR/pc$i.key" \
        -out "$CERT_DIR/pc$i.csr" \
        -subj "/CN=photon-pc$i/O=Photon/C=US" \
        2>/dev/null
    
    # Sign certificate with CA
    openssl x509 -req -in "$CERT_DIR/pc$i.csr" \
        -CA "$CERT_DIR/photon-ca.crt" \
        -CAkey "$CERT_DIR/photon-ca.key" \
        -CAcreateserial \
        -out "$CERT_DIR/pc$i.crt" \
        -days $DAYS_VALID \
        -extensions v3_req \
        2>/dev/null
    
    # Clean up CSR
    rm "$CERT_DIR/pc$i.csr"
done

# Generate client certificate for Photon Master
echo "Generating certificate for Photon Master..."
openssl genrsa -out "$CERT_DIR/photon-master.key" 4096 2>/dev/null
openssl req -new -key "$CERT_DIR/photon-master.key" \
    -out "$CERT_DIR/photon-master.csr" \
    -subj "/CN=photon-master/O=Photon/C=US" \
    2>/dev/null
openssl x509 -req -in "$CERT_DIR/photon-master.csr" \
    -CA "$CERT_DIR/photon-ca.crt" \
    -CAkey "$CERT_DIR/photon-ca.key" \
    -CAcreateserial \
    -out "$CERT_DIR/photon-master.crt" \
    -days $DAYS_VALID \
    2>/dev/null
rm "$CERT_DIR/photon-master.csr"

# Set proper permissions
chmod 600 "$CERT_DIR"/*.key
chmod 644 "$CERT_DIR"/*.crt

echo "Certificate generation complete!"
echo "Certificates stored in: $CERT_DIR"

# Generate pairing configuration for each Sunshine instance
for i in {1..3}; do
    cat > "$CERT_DIR/pc$i-pair.json" << EOF
{
    "hostname": "photon-pc$i",
    "address": "172.20.0.$((9+i))",
    "port": 47989,
    "certificate": "$(base64 -w0 < "$CERT_DIR/pc$i.crt")",
    "paired": true,
    "pin": "$(openssl rand -hex 8)"
}
EOF
done

echo "Pairing configurations generated!"