FROM nginx:1.19.4-alpine

WORKDIR /app

COPY /dist ./
COPY /.build/target/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]