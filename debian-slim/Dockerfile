FROM alpine:3.7 as installer

# Install dependencies
RUN apk add --no-cache gawk unzip git

ARG XLD_VERSION
ENV APP_ROOT=/opt/xebialabs
ENV APP_HOME=${APP_ROOT}/xl-deploy-server

# Install XL Deploy
ADD resources/xl-deploy-${XLD_VERSION}-server.zip /tmp
RUN mkdir -p ${APP_ROOT} && \
    unzip /tmp/xl-deploy-${XLD_VERSION}-server.zip -d ${APP_ROOT} && \
    mv ${APP_ROOT}/xl-deploy-${XLD_VERSION}-server ${APP_HOME}

# Add bin/run-in-container.sh
ADD resources/bin/run-in-container.sh ${APP_HOME}/bin/

# Modify bin/run.sh so that java becomes a child process of dumb-init
RUN sed -i 's/^\($JAVACMD $XL_DEPLOY_SERVER_OPTS\)/exec \1/' ${APP_HOME}/bin/run.sh

# Move and augment conf directory of regular install
RUN mv ${APP_HOME}/conf ${APP_HOME}/default-conf && \
    mkdir ${APP_HOME}/conf
COPY resources/default-conf ${APP_HOME}/default-conf
COPY resources/drivers ${APP_HOME}/drivers

# Modify conf/xld-wrapper-linux.conf to add node-conf to the classpath and to add container-specific VM options
COPY resources/modify-xld-wrapper-linux-conf.gawk /tmp/modify-xld-wrapper-linux-conf.gawk
RUN chmod +x /tmp/modify-xld-wrapper-linux-conf.gawk && \
    /tmp/modify-xld-wrapper-linux-conf.gawk ${APP_HOME}/default-conf/xld-wrapper-linux.conf > /tmp/xld-wrapper-linux.conf && \
    mv /tmp/xld-wrapper-linux.conf ${APP_HOME}/default-conf/xld-wrapper-linux.conf && \
    rm /tmp/modify-xld-wrapper-linux-conf.gawk

# Create node-specific conf directory and add template for node-specific xl-deploy.conf file
RUN mkdir ${APP_HOME}/node-conf
ADD resources/node-conf/xl-deploy.conf.template ${APP_HOME}/node-conf

# Update the plugins directory
RUN rm ${APP_HOME}/plugins/xld-kubernetes-plugin-8.0.1.xldp
COPY resources/newplugins/* ${APP_HOME}/plugins/
RUN ls -lrt ${APP_HOME}/plugins

# Move plugins directory
RUN mv ${APP_HOME}/plugins ${APP_HOME}/default-plugins && \
    mkdir ${APP_HOME}/plugins


# Create empty repository directory
RUN mkdir ${APP_HOME}/repository

# Copy the sample applications
COPY resources/importablePackages/* ${APP_HOME}/importablePackages/

# install kube tools
RUN apk add --no-cache curl
RUN curl -o /usr/local/bin/kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/kubectl
RUN chmod +x /usr/local/bin/kubectl
RUN ln -s /usr/local/bin/kubectl ${APP_HOME}/bin/kubectl
RUN ${APP_HOME}/bin/kubectl version --short --client

RUN curl -o /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/aws-iam-authenticator
RUN chmod +x /usr/local/bin/aws-iam-authenticator
RUN ln -s /usr/local/bin/aws-iam-authenticator ${APP_HOME}/bin/aws-iam-authenticator
RUN ${APP_HOME}/bin/aws-iam-authenticator help

RUN curl -o /tmp/helm.tgz https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-linux-amd64.tar.gz
RUN cd /tmp && tar zxvf /tmp/helm.tgz
RUN mv /tmp/linux-amd64/helm /usr/local/bin
RUN mv /tmp/linux-amd64/tiller /usr/local/bin
RUN chmod +x /usr/local/bin/helm
RUN chmod +x /usr/local/bin/tiller

# Set permissions
RUN chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} && \
    chmod g+x ${APP_HOME}/bin/*.sh

FROM openjdk:8-jdk-slim-stretch
MAINTAINER XebiaLabs Development <docker@xebialabs.com>

LABEL name="xebialabs/xl-deploy" \
      maintainer="docker@xebialabs.com" \
      vendor="XebiaLabs" \
      version="8.2.0" \
      release="6" \
      summary="XL Deploy" \
      description="Enterprise-scale Application Release Automation for any environment" \
      url="https://www.xebialabs.com/xl-deploy"

ENV APP_ROOT=/opt/xebialabs
#ENV USER_UID=10001 APP_ROOT=/opt/xebialabs
ENV APP_HOME=${APP_ROOT}/xl-deploy-server

ADD resources/amd64/tini ${APP_ROOT}/tini
RUN chmod ugo+x ${APP_ROOT}/tini

# Copy installed XL Deploy
COPY --from=installer ${APP_ROOT} ${APP_ROOT}

WORKDIR ${APP_HOME}

# Don't run as root
#USER 10001

VOLUME ["${APP_HOME}/conf", "${APP_HOME}/hotfix/lib", "${APP_HOME}/hotfix/plugins", "${APP_HOME}/ext", "${APP_HOME}/plugins","${APP_HOME}/drivers", "${APP_HOME}/repository"]
EXPOSE 4516

# Environment variables are not expanded when using the exec form of the ENTRYPOINT command. They are
# expanded when using the shell form, but that results in tini running with a PID higher than 1.
ENTRYPOINT ["/opt/xebialabs/tini", "/opt/xebialabs/xl-deploy-server/bin/run-in-container.sh"]
