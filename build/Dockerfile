# Alapértelmezett kép építési fázisa
FROM almalinux:8.10 as builder

ENV ZNUNY_VERS=7.0.18-01

LABEL maintainer="Peter Donka <peter.donka@gmail.com>"

# Telepítsd az alapvető csomagokat és fejlesztési eszközöket
RUN yum update -y && \
    yum install -y wget curl bash epel-release mariadb mariadb-server \
    httpd cpanminus gcc dnf-plugins-core mc bind-utils python2 rsyslog net-tools fetchmail && \
    yum groupinstall -y "Development Tools" && \
    yum config-manager --set-enabled powertools && \
    wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl.py -O /usr/local/bin/systemctl && \
    chmod +x /usr/local/bin/systemctl && \
    systemctl enable rsyslog mariadb httpd && \
    yum install -y https://download.znuny.org/releases/RPMS/rhel/7/znuny-${ZNUNY_VERS}.noarch.rpm && \
    yum install -y "perl(Moo)" \
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
    "perl(DBD::Pg)" && \
    cpanm --force JavaScript::Minifier::XS CSS::Minifier::XS iCal::Parser DateTime::TimeZone Jq && \
    yum clean all

# Másold a konfigurációs fájlt és az indító scriptet az építési szakaszba
COPY znuny_config.cnf /etc/my.cnf.d/znuny_config.cnf
COPY start.sh /start.sh

# Végső kép építése
FROM almalinux:8.10

ENV ZNUNY_VERS=7.0.18-01

LABEL maintainer="Peter Donka <peter.donka@gmail.com>"

# Másold át a szükséges fájlokat az építési fázisból
COPY --from=builder /usr/local/bin/systemctl /usr/local/bin/systemctl
COPY --from=builder /etc/my.cnf.d/znuny_config.cnf /etc/my.cnf.d/znuny_config.cnf
COPY --from=builder /start.sh /start.sh
COPY --from=builder /usr/lib /usr/lib
COPY --from=builder /usr/bin /usr/bin
COPY --from=builder /usr/share/perl5 /usr/share/perl5
COPY --from=builder /etc/httpd /etc/httpd
COPY --from=builder /var/www /var/www

# Rendszerbeállítások
RUN chmod +x /start.sh
RUN sed -i 's/^LoadModule mpm_event_module modules\/mod_mpm_event.so/#LoadModule mpm_event_module modules\/mod_mpm_event.so/' /etc/httpd/conf.modules.d/00-mpm.conf
RUN sed -i 's/^#LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/' /etc/httpd/conf.modules.d/00-mpm.conf

ENTRYPOINT [ "/start.sh" ]
