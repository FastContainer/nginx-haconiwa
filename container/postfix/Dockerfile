FROM haconiwa-container:base

ENV IMAGE_NAME postfix
ENV DEBIAN_FRONTEND noninteractive

RUN apt update -yy && \
    apt install -yy postfix rsyslog

ADD entry.sh /entry.sh
RUN chmod +x /entry.sh

RUN wget https://my-netdata.io/kickstart.sh &&
    /bin/bash ./kickstart.sh all --non-interactive

EXPOSE 25 19999
CMD ["/entry.sh"]
