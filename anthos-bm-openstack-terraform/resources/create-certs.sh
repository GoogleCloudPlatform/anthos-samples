# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Define where to store the generated certs and metadata.
DIR="$(pwd)/tls"

# Optional: Ensure the target directory exists and is empty.
rm -rf "${DIR}"
mkdir -p "${DIR}"

# Create the openssl configuration file. This is used for both generating
# the certificate as well as for specifying the extensions. It aims in favor
# of automation, so the DN is encoding and not prompted.
cat > "${DIR}/openssl.cnf" << EOF
[req]
default_bits = 2048
encrypt_key  = no # Change to encrypt the private key using des3 or similar
default_md   = sha256
prompt       = no
utf8         = yes

# Speify the DN here so we aren't prompted (along with prompt = no above).
distinguished_name = req_distinguished_name

# Extensions for SAN IP and SAN DNS
req_extensions = v3_req

# Be sure to update the subject to match your organization.
[req_distinguished_name]
C  = US
ST = California
L  = The Cloud
O  = Demo
CN = <EXTERNAL_IP>

# Allow client and server auth. You may want to only allow server auth.
# Link to SAN names.
[v3_req]
basicConstraints     = CA:FALSE
subjectKeyIdentifier = hash
keyUsage             = digitalSignature, keyEncipherment
extendedKeyUsage     = clientAuth, serverAuth
subjectAltName       = @alt_names

# Alternative names are specified as IP.# and DNS.# for IP addresses and
# DNS accordingly.
[alt_names]
IP.1  = <EXTERNAL_IP>
IP.2  = <INTERNAL_IP>
DNS.1 = <EXTERNAL_IP>
DNS.2 = <EXTERNAL_IP>:5000
DNS.3 = <EXTERNAL_IP>:9876
DNS.4 = <EXTERNAL_IP>:8780
DNS.5 = <INTERNAL_IP>
DNS.6 = <INTERNAL_IP>:5000
DNS.7 = <INTERNAL_IP>:9876
DNS.8 = <INTERNAL_IP>:8780
EOF

# Create the certificate authority (CA). This will be a self-signed CA, and this
# command generates both the private key and the certificate. You may want to
# adjust the number of bits (4096 is a bit more secure, but not supported in all
# places at the time of this publication).
#
# To put a password on the key, remove the -nodes option.
#
# Be sure to update the subject to match your organization.
openssl req \
  -new \
  -newkey rsa:2048 \
  -days 120 \
  -nodes \
  -x509 \
  -subj "/C=US/ST=California/L=The Cloud/O=My Company CA" \
  -keyout "${DIR}/ca.key" \
  -out "${DIR}/ca.crt"
#
# For each server/service you want to secure with your CA, repeat the
# following steps:
#

# Generate the private key for the service. Again, you may want to increase
# the bits to 4096.
openssl genrsa -out "${DIR}/my-service.key" 2048

# Generate a CSR using the configuration and the key just generated. We will
# give this CSR to our CA to sign.
openssl req \
  -new -key "${DIR}/my-service.key" \
  -out "${DIR}/my-service.csr" \
  -config "${DIR}/openssl.cnf"

# Sign the CSR with our CA. This will generate a new certificate that is signed
# by our CA.
openssl x509 \
  -req \
  -days 120 \
  -in "${DIR}/my-service.csr" \
  -CA "${DIR}/ca.crt" \
  -CAkey "${DIR}/ca.key" \
  -CAcreateserial \
  -extensions v3_req \
  -extfile "${DIR}/openssl.cnf" \
  -out "${DIR}/my-service.crt"

# (Optional) Verify the certificate.
openssl x509 -in "${DIR}/my-service.crt" -noout -text

# Here is a sample response (truncate):
#
# Certificate:
#     Signature Algorithm: sha256WithRSAEncryption
#         Issuer: C = US, ST = California, L = The Cloud, O = My Organization CA
#         Subject: C = US, ST = California, L = The Cloud, O = Demo, CN = My Certificate
#         # ...
#         X509v3 extensions:
#             X509v3 Basic Constraints:
#                 CA:FALSE
#             X509v3 Subject Key Identifier:
#                 36:7E:F0:3D:93:C6:ED:02:22:A9:3D:FF:18:B6:63:5F:20:52:6E:2E
#             X509v3 Key Usage:
#                 Digital Signature, Key Encipherment
#             X509v3 Extended Key Usage:
#                 TLS Web Client Authentication, TLS Web Server Authentication
#             X509v3 Subject Alternative Name:
#                 IP Address:1.2.3.4, DNS:my.dns.name
#
