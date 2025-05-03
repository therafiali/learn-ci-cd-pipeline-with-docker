# FROM node:20-alpine AS builder

# WORKDIR /app

# COPY package.json ./

# RUN npm i

# COPY . .

# RUN npm run build

# EXPOSE 3000

# CMD ["npm", "run", "start"]
# Step 1: Install dependencies
FROM node:20-alpine AS deps
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install --production=false

# Step 2: Build the Next.js app
FROM node:20-alpine AS builder
WORKDIR /app

COPY . .
COPY --from=deps /app/node_modules ./node_modules

RUN npm run build

# Step 3: Create minimal production image
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# Only copy necessary files for production
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000

CMD ["npm", "start"]
