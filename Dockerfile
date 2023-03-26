FROM ubuntu:latest AS builder

ARG TARGETPLATFORM
RUN apt-get update && apt-get install -y curl binutils jq xz-utils && \
    export VERSION=$(curl -s "https://api.github.com/repos/klzgrad/naiveproxy/releases/latest" | jq -r .tag_name) && \
    curl --fail --silent -L https://github.com/klzgrad/naiveproxy/releases/download/${VERSION}/naiveproxy-${VERSION}-linux-x64.tar.xz | tar xJvf - -C / && \
    mv naiveproxy-* naiveproxy && \
    chmod +x naiveproxy/naive && \
    apt-get remove -y curl binutils jq xz-utils && \
    apt-get autopurge -y && \
    rm -rf /var/lib/apt/lists/*

FROM ubuntu:latest

COPY --from=builder /naiveproxy/naive /usr/local/bin/naive
 
RUN echo 'hosts: files dns' > /etc/nsswitch.conf 

 
RUN apt-get update && \
    apt-get install -y iptables ca-certificates bash tzdata &&\
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&\
    apt-get remove -y tzdata &&\
    apt-get autopurge -y &&\
    rm -rf /var/lib/apt/lists/*  
    
CMD ["naive", "config.json" ]
