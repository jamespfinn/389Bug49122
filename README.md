# 389 Directory Server Bug 49122
This is a demo of [Bug 49122](https://fedorahosted.org/389/ticket/49122)

# Steps To Reproduce the Bug:

* Build the container:
```
docker build -t jfinn:389Bug49122 .
```

# Run The container with the demo.sh script:
```
docker run --rm -i --name 389debug -t jfinn:389Bug49122 /tmp/demo.sh
```

# OR run the container and manually reproduce the problem:
```
[root@98efc6936cc6 ~]# /usr/sbin/ns-slapd -D /etc/dirsrv/slapd-myserver/ && sleep 30 # Start the server and give it some time to load
```

```
[root@98efc6936cc6 ~]# time ldapsearch -x -LLL -h localhost -s sub -b dc=mycorp,dc=com -D"cn=directory manager" -wpassword uid=jfinn nsrole
dn: uid=jfinn,ou=People,o=Intra,dc=mycorp,dc=com
nsrole: cn=adm-approved-email,o=intra,dc=mycorp,dc=com
nsrole: cn=adm-approved-mycorp,o=intra,dc=mycorp,dc=com
nsrole: cn=arb-user,o=intra,dc=mycorp,dc=com
nsrole: cn=ldap-adm-tools,o=intra,dc=mycorp,dc=com
nsrole: cn=ldap-dsts,o=intra,dc=mycorp,dc=com
nsrole: cn=myc-myc-assoc,o=intra,dc=mycorp,dc=com
nsrole: cn=myc-myc-corp,o=intra,dc=mycorp,dc=com
nsrole: cn=myc-sys-it,o=intra,dc=mycorp,dc=com
nsrole: cn=sig-preview,o=intra,dc=mycorp,dc=com
nsrole: cn=sys-has-email,o=intra,dc=mycorp,dc=com
nsrole: cn=sys-has-mycorp,o=intra,dc=mycorp,dc=com
nsrole: cn=unix-admins,o=intra,dc=mycorp,dc=com
nsrole: cn=unix-solaris-admins,o=intra,dc=mycorp,dc=com
nsrole: cn=vpn-remoteaccess,o=intra,dc=mycorp,dc=com


real    0m0.035s
user    0m0.002s
sys     0m0.003s
```

```
[root@98efc6936cc6 ~]# cat /tmp/filtered_role_that_includes_empty_role.ldif 
dn: cn=Filtered_Role_That_Includes_Empty_Role,o=Intra,dc=mycorp,dc=com
nsRoleFilter: (!(nsrole=cn=This_Is_An_Empty_Managed_NsRoleDefinition,o=Intra,dc=mycorp,dc=com))
description: A filtered role with filter that will crash the server 
objectClass: top
objectClass: ldapsubentry
objectClass: nsroledefinition
objectClass: nscomplexroledefinition
objectClass: nsfilteredroledefinition
cn: Filtered_Role_That_Includes_Empty_Role
```

```
[root@98efc6936cc6 ~]# ldapadd -x -h localhost -D"cn=directory manager" -wpassword -f /tmp/filtered_role_that_includes_empty_role.ldif
adding new entry "cn=Filtered_Role_That_Includes_Empty_Role,o=Intra,dc=mycorp,dc=com"
```

```
[root@98efc6936cc6 ~]# time ldapsearch -x -LLL -h localhost -s sub -b dc=mycorp,dc=com -D"cn=directory manager" -wpassword uid=jfinn nsrole
ldap_result: Can't contact LDAP server (-1)

real    0m12.590s
user    0m13.091s
sys     0m0.184s
```
