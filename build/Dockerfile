FROM almalinux:8.8 as builder

ENV ZNUNY_VERS=7.0.9-01

LABEL maintainer="Peter Donka <peter.donka@gmail.com>"

FROM builder as build1
# Install Basics
RUN yum update -y
RUN yum install -y epel-release httpd mariadb mariadb-server cpanminus gcc dnf-plugins-core mc bind-utils wget curl python2 rsyslog net-tools
RUN yum groupinstall -y "Development Tools"
RUN yum config-manager --set-enabled powertools

FROM build1 as build2
# Enable systemd
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in ; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done);
RUN rm -rf /lib/systemd/system/multi-user.target.wants/ \
&& rm -rf /etc/systemd/system/.wants/ \
&& rm -rf /lib/systemd/system/local-fs.target.wants/ \
&& rm -f /lib/systemd/system/sockets.target.wants/udev \
&& rm -f /lib/systemd/system/sockets.target.wants/initctl \
&& rm -rf /lib/systemd/system/basic.target.wants/ \
&& rm -f /lib/systemd/system/anaconda.target.wants/*

RUN wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl.py -O /usr/local/bin/systemctl
RUN chmod +x /usr/local/bin/systemctl

FROM build2 as build3
# Install Znuny
RUN yum install -y https://download.znuny.org/releases/RPMS/rhel/7/znuny-$ZNUNY_VERS.noarch.rpm

FROM build3 as build4
# Install Required Perl Modules
RUN yum install -y "perl(Moo)" \
    "perl(Text::CSV_XS)" \
    "perl(YAML::XS)" \
    "perl(ModPerl::Util)" \
    "perl(Mail::IMAPClient)" \
    "perl(JSON::XS)" \
    "perl(Encode::HanExtra)" \
    "perl(Crypt::Eksblowfish::Bcrypt)" \
    "perl(Data::UUID)" \
    "perl(Spreadsheet::XLSX)" \
    "perl(Hash::Merge)" \
    "perl(DBD::ODBC)" \
    "perl(DBD::Pg)"

FROM build4 as build5
RUN cpanm --force JavaScript::Minifier::XS CSS::Minifier::XS iCal::Parser DateTime::TimeZone Jq

FROM build5 as build6
COPY znuny_config.cnf /etc/my.cnf.d/znuny_config.cnf

FROM build6 as build7
RUN sed -i '/^LoadModule mpm_event_module modules\/mod_mpm_event.so/s/^/#/' /etc/httpd/conf.modules.d/00-mpm.conf
RUN sed -i '/^#LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/s/^#//' /etc/httpd/conf.modules.d/00-mpm.conf

COPY start.sh /start.sh
RUN chmod +x /start.sh
ENTRYPOINT [ "/start.sh" ]
