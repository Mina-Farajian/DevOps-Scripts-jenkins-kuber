FROM node:17.9.1-alpine

WORKDIR /var/www

ENV NODE_ENV production

COPY ["package.json", "yarn.lock","/var/www/"]

ARG STAGE=rc

RUN sed -i 's/dl-cdn.alpinelinux.org/nexus.mina.com\/repository\/apk/g' /etc/apk/repositories && \

    apk add --update-cache nginx python2 g++ make && \

    sed -i 's/registry.yarnpkg.com/nexus.mina.com\/repository\/yarn/g' yarn.lock

RUN apk add --update-cache nginx autoconf

RUN cd /var/www  && yarn install --production

ADD [".", "/var/www/"]

#RUN yarn const:pro

RUN yarn build:$STAGE

RUN chmod +x /var/www/entrypoint.sh

ENTRYPOINT ["/var/www/entrypoint.sh"]
