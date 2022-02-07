ARG NODE_VERSION=16.13.2
ARG ALPINE_VERSION=3.15

FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} as dependencies
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn 


FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} as api
WORKDIR /app
COPY --from=dependencies /app/node_modules /app/node_modules
COPY . .
EXPOSE 3000
CMD [ "yarn", "start" ]