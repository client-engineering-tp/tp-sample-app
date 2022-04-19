FROM registry.access.redhat.com/ubi8/nodejs-12:1-107 as base

FROM base as builder

WORKDIR /opt/app-root/src

COPY package*.json ./ 

RUN npm ci 

COPY public public 
COPY src src 

RUN npm run build

FROM base

WORKDIR /opt/app-root/src

COPY --from=builder  /opt/app-root/src/build build

COPY package*.json ./

RUN npm ci --only=production

#COPY --chown=default:root server server
COPY --chown=1001:0 server server
RUN chmod -R g=u server

ENV PORT=8080

LABEL com.example.source="https://github.com/csantanapr/think2020-nodejs"
LABEL com.example.version="1.0"

#ARG ENV=production
#ENV NODE_ENV $ENV
ENV NODE_VERSION $NODEJS_VERSION
#hadolint ignore=DL3025
#CMD npm run $NODE_ENV
#RUN npm run build
CMD npm run production