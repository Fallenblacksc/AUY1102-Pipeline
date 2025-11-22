# ---------------------------------------
# Etapa 1: Dependencias y Compilación
# ---------------------------------------
# CAMBIO 1: Usamos Node 20 para cumplir con tus dependencias (@semantic-release)
FROM node:20-alpine AS builder
WORKDIR /app

# Instalamos dependencias necesarias para compilar en Alpine (python, make, g++)
# A veces son necesarias para 'node-gyp'
RUN apk add --no-cache python3 make g++

COPY package*.json ./

# Instalamos TODAS las dependencias (incluyendo devDependencies)
RUN npm ci

COPY . .

# 1. Ejecutamos las pruebas
RUN npm test

# 2. Compilamos el código TypeScript
RUN npm run build

# ---------------------------------------
# Etapa 2: Imagen de Producción
# ---------------------------------------
FROM node:20-alpine AS production
WORKDIR /app

COPY package*.json ./

# CAMBIO 2: Usamos --omit=dev (estándar moderno) y --ignore-scripts
# --ignore-scripts es LA CLAVE: evita que se ejecute 'prepare' (husky) que causa el error
RUN npm ci --omit=dev --ignore-scripts

# Copiamos solo los archivos compilados desde la etapa "builder"
COPY --from=builder /app/dist ./dist

EXPOSE 3000

CMD ["npm", "start"]