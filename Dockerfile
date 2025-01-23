FROM alpine:latest AS builder

ARG TARGETPLATFORM
RUN apk add --no-cache curl binutils jq xz gcc libc-dev && \
    VERSION=$(curl -s "https://api.github.com/repos/klzgrad/naiveproxy/releases/latest" | jq -r .tag_name) && \
    curl --fail --silent -L https://github.com/klzgrad/naiveproxy/releases/download/${VERSION}/naiveproxy-${VERSION}-openwrt-x86_64.tar.xz | tar xJvf - -C / && \
    mv naiveproxy-* naiveproxy && \
    chmod +x naiveproxy/naive && \
    apk del curl binutils jq xz gcc libc-dev && \
    rm -rf /var/cache/apk/*

FROM alpine:latest

# 安装必要的运行时库，包括 libgcc
RUN apk add --no-cache iptables ca-certificates bash tzdata libgcc && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    apk del tzdata && \
    rm -rf /var/cache/apk/* && \
    echo 'hosts: files dns' > /etc/nsswitch.conf

COPY --from=builder /naiveproxy/naive /usr/local/bin/naive

CMD ["naive", "config.json"]
