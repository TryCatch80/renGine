# Base image
FROM ubuntu:20.04

# Labels and Credits
LABEL \
    name="reNgine" \
    author="Yogesh Ojha <yogesh.ojha11@gmail.com>" \
    description="reNgine is a automated pipeline of recon process, useful for information gathering during web application penetration testing."

# Environment Variables
ENV DEBIAN_FRONTEND="noninteractive" \
    DATABASE="postgres"

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install essentials
RUN apt update -y && apt install -y  --no-install-recommends \
    build-essential \
    cmake \
    firefox \
    gcc \
    git \
    libpq-dev \
    libpq-dev \
    libpcap-dev \
    netcat \
    postgresql \
    python3 \
    python3-dev \
    python3-pip \
    python3-netaddr \
    wget \
    x11-utils \
    xvfb \
    python3-cffi \
    python3-brotli \
    libpango-1.0-0 \
    libpangoft2-1.0-0 \
    geoip-bin \
    geoip-database \
    nano \
    curl \
    whois \
    tree \
    libnss3-dev \
    libgbm-dev


# Download and install go 1.17
RUN wget https://go.dev/dl/go1.19.2.linux-amd64.tar.gz
RUN tar -xvf go1.19.2.linux-amd64.tar.gz
RUN rm go1.19.2.linux-amd64.tar.gz
RUN mv go /usr/local

# Download geckodriver
RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.26.0/geckodriver-v0.26.0-linux64.tar.gz
RUN tar -xvf geckodriver-v0.26.0-linux64.tar.gz
RUN rm geckodriver-v0.26.0-linux64.tar.gz
RUN mv geckodriver /usr/bin

# ENV for Go
ENV GOROOT="/usr/local/go"
ENV PATH="${PATH}:${GOROOT}/bin"
ENV PATH="${PATH}:${GOPATH}/bin"

ENV GOPATH=$HOME/go
ENV PATH="${PATH}:${GOROOT}/bin:${GOPATH}/bin"

# Make directory for app
WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Download Go packages
RUN go install -v github.com/hakluke/hakrawler@latest

RUN GO111MODULE=on go install -v -v github.com/bp0lr/gauplus@latest

RUN GO111MODULE=on go install -v github.com/jaeles-project/gospider@latest

RUN go install -v github.com/OWASP/Amass/v3/...@latest

RUN go install -v github.com/ffuf/ffuf@latest

RUN go install -v github.com/tomnomnom/assetfinder@latest
RUN GO111MODULE=on go install -v github.com/tomnomnom/gf@latest
RUN GO111MODULE=on go install -v github.com/tomnomnom/unfurl@latest
RUN GO111MODULE=on go install -v github.com/tomnomnom/waybackurls@latest
RUN GO111MODULE=on go install -v github.com/NightRang3r/tldend@main
RUN GO111MODULE=on go install -v github.com/j3ssie/str-replace@latest
RUN GO111MODULE=on go install -v github.com/hakluke/haktrails@latest 
RUN GO111MODULE=on go install -v github.com/d3mondev/puredns/v2@latest
RUN GO111MODULE=on go install -v github.com/subfinder/goaltdns@master
RUN GO111MODULE=on go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
RUN GO111MODULE=on go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
RUN GO111MODULE=on go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
RUN GO111MODULE=on go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
RUN GO111MODULE=on go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
RUN GO111MODULE=on go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest
RUN GO111MODULE=on go install -v github.com/lc/gau/v2/cmd/gau@latest
RUN GO111MODULE=on go install -v github.com/xm1k3/cent@latest
RUN GO111MODULE=on go install -v github.com/glebarez/cero@latest
RUN GO111MODULE=on go install -v github.com/NightRang3r/subress@main
RUN GO111MODULE=on go install -v github.com/gwen001/github-subdomains@latest
RUN GO111MODULE=on go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest
RUN GO111MODULE=on go install -v github.com/Josue87/gotator@latest
RUN GO111MODULE=on go install -v github.com/cgboal/sonarsearch/cmd/crobat@latest
RUN GO111MODULE=on go install -v github.com/projectdiscovery/katana/cmd/katana@latest
RUN GO111MODULE=on go install -v github.com/gwen001/gitlab-subdomains@latest
RUN GO111MODULE=on go install -v github.com/trickest/mksub@latest
RUN GO111MODULE=on go install -v github.com/trickest/dsieve@latest
# Update Nuclei and Nuclei-Templates
RUN nuclei -update
RUN nuclei -update-templates

# Copy requirements
COPY ./requirements.txt /tmp/requirements.txt
RUN pip3 install --upgrade setuptools pip && \
    pip3 install -r /tmp/requirements.txt && pip3 install anubis-netsec

# install eyewitness

RUN python3 -m pip install fuzzywuzzy \
    selenium \
    python-Levenshtein \
    pyvirtualdisplay \
    netaddr

RUN python3 -m pip install aiodnsbrute

RUN git clone https://github.com/blechschmidt/massdns.git /usr/src/github/massdns
RUN cd /usr/src/github/massdns && make && make install

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && echo 'source /root/.cargo/env' >> /root/.bashrc && export PATH="/root/.cargo/bin:$PATH"
ENV PATH="/root/.cargo/bin:${PATH}"

RUN cargo install ripgen

# Copy source code
COPY . /usr/src/app/

ADD tools/resolvers.txt /root/.config/resolvers.txt
ADD tools/trusted_resolvers.txt /root/.config/trusted_resolvers.txt
ADD tools/config.yaml /root/.config/subfinder/config.yaml
ADD tools/cent.yaml /root/.config/cent.yaml
ADD tools/provider-config.yaml /root/.config/subfinder/provider-config.yaml
#ADD tools/SonarSearch /root/SonarSearch
ADD tools/ssto /go/bin/ssto
#RUN cd /root/SonarSearch/cmd/crobat && go install
#ADD tools/github-subdomains /root/github-subdomains
#RUN cd /root/github-subdomains && go install 


# httpx seems to have issue, use alias instead!!!
RUN echo 'alias httpx="/go/bin/httpx"' >> ~/.bashrc
