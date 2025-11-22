# ---------------------------------------
# Etapa 1: Dependencias y Compilación
# ---------------------------------------
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
# Instalamos todas las dependencias (incluyendo devDependencies para poder compilar)
RUN npm ci

COPY . .

# 1. Ejecutamos las pruebas (Requisito del Pipeline)
# Si esto falla, la construcción de la imagen se detiene.
RUN npm test

# 2. Compilamos el código TypeScript a JavaScript (crea la carpeta /dist)
RUN npm run build

# ---------------------------------------
# Etapa 2: Imagen de Producción (Ligera)
# ---------------------------------------
FROM node:18-alpine AS production
WORKDIR /app

COPY package*.json ./
# Solo instalamos dependencias de producción (ahorramos espacio y seguridad)
RUN npm ci --only=production

# Copiamos solo los archivos compilados desde la etapa "builder"
COPY --from=builder /app/dist ./dist

# Exponemos el puerto (ajusta si tu app usa otro, ej 8080)
EXPOSE 3000

# Comando de inicio (usa el script start que acabamos de crear)
CMD ["npm", "start"]