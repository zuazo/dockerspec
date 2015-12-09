FROM alpine:3.2
MAINTAINER John Doe "john.doe@example.com"

LABEL testing=docker serverspec=true description="My Container"

ARG user1
ARG buildno=1

ENV PATH /usr/sbin:/usr/bin:/sbin:/bin

ENV container=docker CRACKER="RANDOM;PATH=/tmp/bin:/sbin:/bin"

WORKDIR /opt

USER nobody

EXPOSE 80

VOLUME /volume1 /volume2

ADD files/file_example1 /tmp/file_example1

COPY files/file_example2 /tmp/file_example2

RUN ["echo", "running"]

ENTRYPOINT ["sleep"]
CMD ["2", "2000"]
ONBUILD RUN echo onbuild
STOPSIGNAL SIGTERM
