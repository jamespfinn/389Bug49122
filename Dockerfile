FROM centos:centos7
MAINTAINER Jim Finn jamespfinn@gmail.com 
LABEL Description="This image is to demonstrate a bug in the nsrole cache of 389 directory server"
RUN yum install -y epel-release && yum update -y
RUN yum install -y vim wget 389-ds-base openldap-clients
COPY files/mycorp.ldif.gz /tmp/
RUN gunzip /tmp/mycorp.ldif.gz
COPY files/empty_managed_role.ldif /tmp/
COPY files/filtered_role_that_includes_empty_role.ldif /tmp/
COPY files/ds-setup.inf /tmp/
RUN rm -fr /var/lock /usr/lib/systemd/system \
    # The 389-ds setup will fail because the hostname can't reliable be determined, so we'll bypass it and then install. \
    && sed -i 's/checkHostname {/checkHostname {\nreturn();/g' /usr/lib64/dirsrv/perl/DSUtil.pm \
    # Not doing SELinux \
    && sed -i 's/updateSelinuxPolicy($inf);//g' /usr/lib64/dirsrv/perl/* \
    # Do not restart at the end \
    && sed -i '/if (@errs = startServer($inf))/,/}/d' /usr/lib64/dirsrv/perl/* 
RUN setup-ds.pl --silent --file /tmp/ds-setup.inf \
    && sed -i 's/nsslapd-schemacheck: on/nsslapd-schemacheck: off/g;s/nsslapd-syntaxcheck: on/nsslapd-syntaxcheck: off/g' /etc/dirsrv/slapd-myserver/dse.ldif \
    && /usr/lib64/dirsrv/slapd-myserver/ldif2db -n userRoot -i /tmp/mycorp.ldif \
    && /usr/sbin/ns-slapd -D /etc/dirsrv/slapd-myserver \
    && sleep 5 \
    && ldapadd -x -h localhost -D"cn=directory manager" -wpassword -f /tmp/empty_managed_role.ldif 
COPY files/demo.sh /tmp/

