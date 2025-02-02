FROM node:18-alpine

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install --only=production

COPY . .

RUN npm install --save-dev @types/node

RUN npm run build

EXPOSE 3000

CMD ["node", "dist/index.js"]
