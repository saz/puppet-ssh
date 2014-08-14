#!/bin/bash

ldapsearch -LLLx uid=${1} sshPublicKey | grep -v "^dn" | perl -p00e 's/\r?\n //g' | perl -pe 's/sshPublicKey: //' | perl -pe 's/$/\n/'
