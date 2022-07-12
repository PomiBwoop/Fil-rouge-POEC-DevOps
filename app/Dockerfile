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
EXPOSE 80
# COMMANDE DE LANCEMENT DU CONTENEUR AVEC EVENTUELS ARGUMENTS
ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]

