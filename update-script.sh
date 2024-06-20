#!/bin/bash

domain=[your toplevel domain e.g. mailserver.de]
domain_prefix=[your supdomain prefix e.g. mx2]
test_port=465
desec_token=[your deSEC API Token]

echo "Starting DANE TLSA update..."
host_name=$domain_prefix.$domain
cd /usr/local/psa/var/certificates/
certificate_name=$(/usr/sbin/plesk db "select cert_file from certificates where name like '%$host_name%'" | awk 'NR==4 {print $2}')


hash=$(openssl x509 -in $certificate_name -pubkey -noout | openssl rsa -pubin -outform der 2>/dev/null | sha256sum | grep -oP '^[a-f0-9]{64}')
tlsa_record="3 1 1 $hash"

dane_test=$(\
openssl s_client -brief \
 -dane_tlsa_domain $host_name \
 -dane_tlsa_rrdata "$tlsa_record" \
 -connect $host_name:$test_port <<< "Q" 2>&1 )


if echo "$dane_test" | grep -q 'Verification: OK'; then
  echo "Verification succeeded. Proceeding..."

data=$(cat <<-EOF
[
   {
        "subname": "",
        "type": "TLSA",
        "ttl": 3600,
        "records": ["$tlsa_record"]
   },
   {
        "subname": "_995._tcp.$domain_prefix",
        "type": "TLSA",
        "ttl": 3600,
        "records": ["$tlsa_record"]
   },
   {
        "subname": "_993._tcp.$domain_prefix",
        "type": "TLSA",
        "ttl": 3600,
        "records": ["$tlsa_record"]
   },
   {
        "subname": "_587._tcp.$domain_prefix",
        "type": "TLSA",
        "ttl": 3600,
        "records": ["$tlsa_record"]
   },
   {
        "subname": "_465._tcp.$domain_prefix",
        "type": "TLSA",
        "ttl": 3600,
        "records": ["$tlsa_record"]
   },
   {
        "subname": "_110._tcp.$domain_prefix",
        "type": "TLSA",
        "ttl": 3600,
        "records": ["$tlsa_record"]
   },
   {
        "subname": "_25._tcp.$domain_prefix",
        "type": "TLSA",
        "ttl": 3600,
        "records": ["$tlsa_record"]
   }
]
EOF
)


res=$(curl -i -X PUT https://desec.io/api/v1/domains/$domain/rrsets/ \
    --header "Authorization: Token $desec_token" \
    --header "Content-Type: application/json" \
    --data "$data" 2>&1)

if echo "$res" | grep -q 'HTTP/2 200'; then
  echo "DNS Update succeeded."
else
 echo $res
fi

else
  echo "Verification failed. Aborting..."
fi 
