
# NOTES:
#   Base Image:  https://hub.docker.com/_/microsoft-powershell
#   Application: https://github.com/hashicorp/http-echo
#
#   Use the PowerShell version of NanoServer to make installation easier/dynamic.
#   Put the app in a subdirectory to avoid security errors during installation.
#
#   Variables are fed from the BuildTasks section of the ado-pipeline.yml file.
#

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

ARG APP_VERSION=0.2.3

SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Write-Host "Application Version: $($env:APP_VERSION)"; \
    Write-Host "URI: https://github.com/hashicorp/http-echo/releases/download/v$($env:APP_VERSION)/http-echo_$($env:APP_VERSION)_windows_amd64.zip"; \
    New-Item \
        -ItemType directory \
        -Path "/http-echo"; \
    Invoke-WebRequest \
        -Uri "https://github.com/hashicorp/http-echo/releases/download/v$($env:APP_VERSION)/http-echo_$($env:APP_VERSION)_windows_amd64.zip" \
        -OutFile "/http-echo/http-echo.zip"; \
    Expand-Archive \
        -Path "/http-echo/http-echo.zip" \
        -DestinationPath "/http-echo/" \
        -Force; \
    Rename-Item \
        -Path "/http-echo/http-echo" \
        -NewName "http-echo.exe"; \
    Remove-Item \
        -Path "/http-echo/http-echo.zip" \
        -Force;

EXPOSE 80
ENTRYPOINT [ "/http-echo/http-echo.exe", "-listen=:80", "-text=I'm Up!" ]

LABEL org.opencontainers.image.title="HTTP-Echo" \
      org.opencontainers.image.description="A tiny go web server that echos what you start it with!" \
      org.opencontainers.image.documentation="https://github.com/hashicorp/http-echo" \
      org.opencontainers.image.base.name="mcr.microsoft.com/powershell:nanoserver-1809" \
      org.opencontainers.image.version="${APP_VERSION}" \
      org.opencontainers.image.url="https://hub.docker.com/r/seabopo/http-echo" \
      org.opencontainers.image.vendor="seabopo" \
      org.opencontainers.image.authors="seabopo @ Azure Devops / GitHub"

#-Uri "https://github.com/hashicorp/http-echo/releases/download/v$($env:APP_VERSION)/http-echo_$($env:APP_VERSION)_windows_amd64.zip" \
