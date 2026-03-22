# Stage 1: Build the Vite app
FROM node:24-alpine AS builder

WORKDIR /app

# Enable pnpm 10
RUN corepack enable && corepack prepare pnpm@10 --activate

# Copy only lock + package for better caching
COPY package.json pnpm-lock.yaml ./

# Install deps (cached layer)
RUN pnpm install --frozen-lockfile

# Copy rest of code
COPY . .

# Build
RUN pnpm build


# Stage 2: Serve with nginx
FROM nginx:1.27-alpine

# Remove default nginx files
RUN rm -rf /usr/share/nginx/html/*

# Copy build output
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Add proper cache headers (optional but good)
RUN echo "gzip on;" >> /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]