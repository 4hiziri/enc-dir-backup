#!/bin/sh

if [ $# -lt 3 ]
then
    echo "$0 <keyfile> <out> [files]"
    exit 1
fi

keyfile="$1" # can use openssh priv-key
keylen='200'
enc_alg='-aes-256-ctr'
output="$2"

if [ ! -e $output ]
then
    mkdir -p $output
fi

shift 2

# input password for keyfile
stty -echo
read -p "Password for $keyfile: " pass
stty echo

while [ $# != 0 ]
do
    temp=$(mktemp)
    apg -a 1 -n 10 -m"$keylen" -x"$keylen" | shuf -n 1 > $temp # make password for each data

    cat $temp | openssl rsautl -encrypt -inkey $keyfile -out "${output%/}/$(basename $1).key" -passin pass:$pass
    
    tar cz "$1" | openssl enc -e $enc_alg -out "${output%/}/$(basename $1).tar.gz.enc" -kfile $temp
        
    shred -uzn 10 $temp
    shift
done
