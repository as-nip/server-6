# Dockerfile
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/aspnet:11.0-alpine-amd64

WORKDIR /app

RUN apk update && apk upgrade \
    && apk add --no-cache \
    ca-certificates-bundle \
    tzdata \
    icu-libs \
    musl-dev \
    build-base \
    libmsquic \
    dotnet10-sdk \
    aspnetcore10-runtime \
    git \
    wget \
    curl
    
RUN mkdir -p /etc/dns /opt/technitium/dns

RUN git clone --depth 1 https://github.com/TechnitiumSoftware/TechnitiumLibrary.git TechnitiumLibrary
RUN git clone --depth 1 https://github.com/TechnitiumSoftware/DnsServer.git DnsServer

RUN dotnet build TechnitiumLibrary/TechnitiumLibrary.ByteTree/TechnitiumLibrary.ByteTree.csproj -c Release
RUN dotnet build TechnitiumLibrary/TechnitiumLibrary.Net/TechnitiumLibrary.Net.csproj -c Release
RUN dotnet build TechnitiumLibrary/TechnitiumLibrary.Security.OTP/TechnitiumLibrary.Security.OTP.csproj -c Release
    
RUN dotnet publish DnsServer/DnsServerApp/DnsServerApp.csproj -c Release

WORKDIR /app/opt/technitium/dns

ENTRYPOINT ["/bin/sh/dotnet", "/app/opt/technitium/dns/DnsServerApp.dll"]
CMD ["/app/etc/dns"]

EXPOSE \
    53/udp 53/tcp \
    853/udp 853/tcp \
    443/udp 443/tcp \
    80/tcp 8053/tcp \
    5380/tcp 53443/tcp \
    67/udp

LABEL org.opencontainers.image.title="Server-67 DNS"
LABEL org.opencontainers.image.source="https://github.com/as-nip/server-6"

