# =========================
# Build stage
# =========================
FROM node:22-alpine3.22 AS builder

RUN apk update && apk upgrade --no-cache && \
    apk upgrade libcrypto3 && \
    apk upgrade libssl3 && \
    apk upgrade busybox && \
    apk upgrade zlib

WORKDIR /home/node/app

ARG NPM_TOKEN
ARG REVIEW_API_URL
ARG QUESTION_API_URL
ARG WIDGET_URL
ARG WIDGET_MEDIA_PROJECTID
ARG WIDGET_MEDIA_DATASET
ARG WIDGET_MEDIA_TOKEN

COPY package*.json ./
COPY .npmrc ./

RUN rm -rf package-lock.json
RUN npm install
RUN rm -f .npmrc

COPY . .

RUN npm run build

# =========================
# Runtime stage
# =========================
FROM node:22-alpine3.22

RUN apk update && apk upgrade --no-cache && \
    apk upgrade libcrypto3 && \
    apk upgrade libssl3 && \
    apk upgrade busybox && \
    apk upgrade zlib

WORKDIR /home/node/app

COPY --from=builder /home/node/app /home/node/app

# Remove npm CLI to avoid npm internal CVEs
RUN rm -rf /usr/local/lib/node_modules/npm

EXPOSE 3000

CMD ["node", "app.js"]