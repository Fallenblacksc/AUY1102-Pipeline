# ---------------------------------------
# Etapa 1: Dependencias y Compilación
# ---------------------------------------
FROM node:20-alpine AS builder
WORKDIR /app
RUN apk add --no-cache python3 make g++
COPY package*.json ./
RUN npm install
COPY . .

# 1. Ejecutar tests con la ruta directa
RUN ./node_modules/.bin/jest --passWithNoTests

# 2. Compilar el código con la ruta directa
RUN ./node_modules/.bin/rimraf dist && ./node_modules/.bin/tsc

# ---------------------------------------
# Etapa 2: Imagen de Producción
# ---------------------------------------
FROM node:20-alpine AS production
WORKDIR /app

COPY package*.json ./

RUN apk add --no-cache python3 make g++ && \
    npm install --omit=dev --ignore-scripts && \
    apk del python3 make g++

COPY --from=builder /app/dist ./dist

EXPOSE 3000

CMD ["npm", "start"]