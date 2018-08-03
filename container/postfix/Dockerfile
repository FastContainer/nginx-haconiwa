FROM haconiwa-container:base

ENV IMAGE_NAME postfix
ENV DEBIAN_FRONTEND noninteractive

RUN apt update -yy && \
    apt install -yy postfix rsyslog

ADD entry.sh /entry.sh
RUN chmod +x /entry.sh

EXPOSE 25
CMD ["/entry.sh"]
