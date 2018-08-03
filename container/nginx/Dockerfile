FROM haconiwa-container-base:latest

ENV IMAGE_NAME nginx
RUN apt update -yy && \
    apt install -yy nginx

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
