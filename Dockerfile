FROM registry.access.redhat.com/ubi9/ubi:latest

ENV ROLES_ANYWHERE_VERSION=1.4.0
ENV ROLES_ANYWHERE_ARCH=X86_64
ENV ROLES_ANYWHERE_OS=Linux

RUN yum install -y python3-pip

# Install AWS CLI using pip
RUN pip3 install awscli

# Download and install aws_signing_helper for Roles Anywhere
RUN curl -sSL "https://rolesanywhere.amazonaws.com/releases/${ROLES_ANYWHERE_VERSION}/${ROLES_ANYWHERE_ARCH}/${ROLES_ANYWHERE_OS}/aws_signing_helper" -o /usr/local/bin/aws_signing_helper
RUN chmod +x /usr/local/bin/aws_signing_helper

RUN aws --version
RUN aws_signing_helper version

CMD ["/bin/bash"]
