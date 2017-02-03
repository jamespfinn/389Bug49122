#!/bin/bash
set -x 
echo "Starting the directory server..."
/usr/sbin/ns-slapd -D /etc/dirsrv/slapd-myserver/

wait=30
echo "Waiting $wait seconds for it to load..."
sleep $wait

echo "Demonstrating a working ldapsearch before adding the problematic role ... "
time ldapsearch -x -LLL -h localhost -s sub -b dc=mycorp,dc=com -D"cn=directory manager" -wpassword uid=jfinn nsrole

badRole=/tmp/filtered_role_that_includes_empty_role.ldif
echo "This is the role to be added ($badRole): "
cat $badRole

echo "Adding the bad role to the directory..."
ldapadd -x -h localhost -D"cn=directory manager" -wpassword -f $badRole

echo "Demonstrating the crash as result of the addition of the problematic role.."
time ldapsearch -x -LLL -h localhost -s sub -b dc=mycorp,dc=com -D"cn=directory manager" -wpassword uid=jfinn nsrole
