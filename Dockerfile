# Build stage
FROM node:18-alpine AS builder
WORKDIR /app

# Copy package files first (better layer caching)
COPY package*.json ./
RUN npm ci

# Copy source files
COPY prisma ./prisma/
COPY next.config.js ./
COPY tsconfig.json ./
COPY public ./public/
COPY app ./app/
COPY lib ./lib/

# Ggenerate Prisma client
RUN npx prisma generate

# Build Next.js application
RUN npm run build

# Production stage
FROM node:18-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Add non-root user for security
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
USER nextjs

# Copy necessary files from builder
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder --chown=nextjs:nodejs /app/node_modules/@prisma ./node_modules/@prisma
COPY --from=builder --chown=nextjs:nodejs /app/prisma ./prisma

# Expose port
EXPOSE 3000

# Start the application
CMD ["node", "server.js"]