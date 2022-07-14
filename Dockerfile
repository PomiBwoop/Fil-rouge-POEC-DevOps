########################
# IMAGE DE BASE = ALPINE
########################

FROM nginx:stable-alpine
LABEL maintainer="devops-team-4" email="abdoulaye.mady.ndiaye@gmail.com"
# MISE A JOUR
RUN apk update
# NETTOYAGE REPERTOIRE HTML
RUN rm -Rf /usr/share/nginx/html/*
# COPY DES FICHIERS HTML DU SITE WEB STATIQUE
ADD  app/code/*   /usr/share/nginx/html/
# EXOSITION DE PORT (IL FAUDRA QUAND MEME EXPOSER AVEC -P LORS DU LANCEMENT DU CONTENEUR
#EXPOSE 80

# Run the image as a non-root user
RUN adduser -D myuser
USER myuser

# Run the app.  CMD is required to run on Heroku
# $PORT is set by Heroku			
CMD gunicorn --bind 0.0.0.0:$PORT wsgi 


# COMMANDE DE LANCEMENT DU CONTENEUR AVEC EVENTUELS ARGUMENTS
ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]
