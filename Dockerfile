FROM node:18-alpine

WORKDIR /app

# Copier les fichiers de dépendances depuis backend/
COPY backend/package*.json ./

# Installer les dépendances
RUN npm install --omit=dev

# Copier le code source depuis backend/
COPY backend/*.js ./

# Exposer le port
EXPOSE 3000

# Variables d'environnement par défaut
ENV NODE_ENV=production
ENV PORT=3000

# Utilisateur non-root pour la sécurité
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001
USER nodejs

# Démarrer l'application
CMD ["node", "server.js"]
