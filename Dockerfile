FROM node:14-alpine3.18

COPY . .

WORKDIR /usr/src/app/

RUN npm version
