# TSP Project

FROM python:3.9
MAINTAINER Mina farajian
ENV PYTHONUNBUFFERED 1
ENV TZ="Asia/Tehran"
# Install System requirnment pakcages
RUN sed -i 's/deb.debian.org/nexus.mina.test\/repository/g' /etc/apt/sources.list && \

    sed -i 's/deb.debian.org\/debian-security/nexus.tmina.test\/repository\/deb-security/g' /etc/apt/sources.list && \

    apt-get -o Acquire::Check-Valid-Until=false  update && apt-get -y install \

    nginx \

    build-essential \

    wget \

    git \

    default-libmysqlclient-dev

# Copy requirenments
COPY ["entrypoint.sh", "requirements.txt", "/"]
COPY ["pip.conf", "/etc"]
# Install python packages

RUN pip3 install uwsgi
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy project files

COPY [".", "/var/www"]
RUN apt-get autoremove --purge -y  gcc && \

        chmod +x /entrypoint.sh && \

        # chmod +x /var/www/wkhtmltopdf && \

        chown -R www-data. /var/www

WORKDIR "/var/www"
ENTRYPOINT ["/entrypoint.sh"]

