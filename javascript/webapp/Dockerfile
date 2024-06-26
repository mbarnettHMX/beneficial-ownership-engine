FROM mcr.microsoft.com/cbl-mariner/base/nodejs:16

WORKDIR /app
COPY ./build ./build
COPY package.deployed.json package.json
RUN npm install --production
RUN npm install -g pm2
ENTRYPOINT ["pm2-runtime", "start", "npm", "--name", "your-app-name", "--", "start", "--", "--port", "3000"]

