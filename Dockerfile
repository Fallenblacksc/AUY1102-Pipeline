# ---------------------------------------
# Etapa 1: Dependencias y Compilación
# ---------------------------------------
FROM node:20-alpine AS builder
WORKDIR /app
RUN apk add --no-cache python3 make g++
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm test
RUN npm run build

# ---------------------------------------
# Etapa 2: Imagen de Producción
# ---------------------------------------
FROM node:20-alpine AS production
WORKDIR /app

COPY package*.json ./

# 1. Instalar herramientas de compilación temporalmente
RUN apk add --no-cache python3 make g++

# 2. Instalar dependencias de producción
RUN npm ci --omit=dev --ignore-scripts

# 3. Eliminar herramientas de compilación para mantener la imagen ligera
RUN apk del python3 make g++

COPY --from=builder /app/dist ./dist

EXPOSE 3000

CMD ["npm", "start"]