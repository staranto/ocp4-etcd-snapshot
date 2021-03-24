#FROM registry.access.redhat.com/rhel7/rhel-tools
#FROM bash
# RUN apk add openssh rsync  

FROM fedora
RUN yum install -y openssh-clients rsync && \
    yum clean all && \
    rm -rf /var/cache
