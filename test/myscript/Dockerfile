FROM mcr.microsoft.com/powershell:latest

RUN apt-get update && \
    apt-get install -y 7zip && \
    pwsh -Command "Install-Module Pester -Force"

COPY . /app
WORKDIR /app