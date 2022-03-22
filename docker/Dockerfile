FROM postgres:12

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

RUN \
 apt-get update \
 && apt-get install --no-install-recommends -y \
   apt-transport-https ca-certificates curl lsb-release \
 && curl -s -L -o key.gpg https://rm.nextgis.com/api/repo/11/deb/key.gpg && apt-key add key.gpg \
 && echo "deb https://rm.nextgis.com/api/repo/11/deb $(lsb_release -cs) main" | tee -a /etc/apt/sources.list \
 && apt-get update \
 && apt-cache policy postgresql-12-postgis-3 \
 && apt-get install --no-install-recommends -y \
   postgresql-12-postgis-3=3.0.1+0 \
   postgresql-12-postgis-3-scripts=3.0.1+0 \
   postgresql-12-osml10n \
 && apt-get clean && apt-get autoclean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/man/?? /usr/share/man/??_* \
 && mkdir -p /docker-entrypoint-initdb.d

COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/postgis.sh
COPY ./update-postgis.sh /usr/local/bin
