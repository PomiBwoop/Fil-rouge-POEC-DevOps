FROM nginx:stable-alpine
LABEL maintainer="Team-4" email="abdoulaye.mady.ndiaye@gmail.com"
RUN apk update
ADD  Appli/code/ /usr/share/nginx/html/
EXPOSE 8080
ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]