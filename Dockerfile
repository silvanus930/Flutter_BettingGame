FROM nginx:alpine
COPY VERSION.txt /www/
COPY assets/html/goldenRace.html /www/
ARG FLAVOR_NAME=demo
COPY build/app/outputs/flutter-apk/app-${FLAVOR_NAME}-release.apk /www/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]