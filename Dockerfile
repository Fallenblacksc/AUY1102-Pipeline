FROM node:20-alpine

COPY . .

WORKDIR /usr/src/app/

RUN npm version
