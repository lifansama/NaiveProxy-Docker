FROM alpine:latest AS builder

ARG TARGETPLATFORM
RUN apk add --no-cache curl binutils jq xz && \
    VERSION=$(curl -s "https://api.github.com/repos/klzgrad/naiveproxy/releases/latest" | jq -r .tag_name) && \
    curl --fail --silent -L https://github.com/klzgrad/naiveproxy/releases/download/${VERSION}/naiveproxy-${VERSION}-linux-x64.tar.xz | tar xJvf - -C / && \
    mv naiveproxy-* naiveproxy && \
    chmod +x naiveproxy/naive && \
    apk del curl binutils jq xz && \
    rm -rf /var/cache/apk/*

FROM alpine:latest

RUN apk add --no-cache iptables ca-certificates bash tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    apk del tzdata && \
    rm -rf /var/cache/apk/* && \
    echo 'hosts: files dns' > /etc/nsswitch.conf

COPY --from=builder /naiveproxy/naive /usr/local/bin/naive

CMD ["naive", "config.json"]
