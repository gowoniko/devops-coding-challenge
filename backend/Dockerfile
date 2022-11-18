FROM node:16-alpine
RUN mkdir -p app
WORKDIR app/

COPY package.json .
COPY package-lock.json .
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "run", "start"]
