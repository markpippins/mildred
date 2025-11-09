FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies - use npm install if no lockfile exists, otherwise ci
RUN if [ -f "package-lock.json" ]; then npm ci; else npm install; fi

# Copy source code
COPY . .

# Expose port
EXPOSE 3000

# Start development server
CMD ["npm", "run", "dev"]