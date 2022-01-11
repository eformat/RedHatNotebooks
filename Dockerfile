FROM python:3.10

RUN apt update -y && \ 
    apt install jq -y

RUN mkdir -p /tmp/rhnb  && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/rhnb/awscliv2.zip"  && \
    unzip -o -q "/tmp/rhnb/awscliv2.zip" -d "/tmp/rhnb/"  && \
    su -c "/tmp/rhnb/aws/install --update"  && \
    rm -rf /tmp/rhnb/awscliv2.zip  

ENV ROSA_URL=https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/rosa/latest/rosa-linux.tar.gz

RUN mkdir -p /tmp/rhnb  && \
    wget -O /tmp/rhnb/rosa-linux.tar.gz $ROSA_URL && \ 
    tar zxvf /tmp/rhnb/rosa-linux.tar.gz -C  /tmp/rhnb/ && \
    su -c "mv  /tmp/rhnb/rosa /usr/local/bin/" && \ 
    rm /tmp/rhnb/rosa-linux.tar.gz

RUN pip install --no-cache notebook
ENV HOME=/tmp

### create user with a home directory
ARG NB_USER
ARG NB_UID
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}
WORKDIR ${HOME}

# Make sure the contents of our repo are in ${HOME}
COPY . ${HOME}

USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}
