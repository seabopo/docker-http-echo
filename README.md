\
**Introduction**
================

[HTTP-ECHO](https://github.com/hashicorp/http-echo) by HashiCorp is a small go web server that serves a single
HTTP web page whose content is determined by the Docker image startup parameters.

The [official HTTP-ECHO Docker repo](https://hub.docker.com/r/hashicorp/http-echo/tags) only supports 
a linux/amd64 image. This repo adds support for Windows Nano Server based on 
[Microsoft's PowerShell](https://hub.docker.com/_/microsoft-powershell) images and the 
[HTTP-ECHO GitHub Project](https://github.com/hashicorp/http-echo)

Sample [Docker Hub Images](https://hub.docker.com/r/seabopo/http-echo) / Tags:
+ seabopo/http-echo:nanoserver-1809
+ seabopo/http-echo:nanoserver-1809-v0.2.3
+ seabopo/http-echo:nanoserver-ltsc-2022
+ seabopo/http-echo:nanoserver-ltsc-2022-v2.3


\
**Getting Started**
-------------------
\
Sample Docker command to expose run the image on port 8080 of the Docker host:
```
docker run -p 8080:80 seabopo/http-echo -text="hello world" -listen=:80
```

\
Sample Nomad job:
```
job "http-echo" {

  region      = "local"
  datacenters = ["host"]
  type        = "service"

  group "http-echo" {

    count = 1

    network {
      port "http" {
        to = 80
      }
    }

    task "http-echo" {

      driver = "docker"

      config {
        image = "seabopo/http-echo:nanoserver-1809"
        ports = ["http"]
        args = [
          "-listen=:80",
          "-text=Up!"
        ]
      }

      resources {
        cpu    = 200
        memory = 256
      }

      service {
        name = "http-echo"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.http-echo.rule=Host(`http-echo.local`)",
          "traefik.http.services.http-echo.loadbalancer.sticky.cookie=true",
          "traefik.http.services.http-echo.loadbalancer.sticky.cookie.name=ApplicationAffinity",
        ]

        check {
            type     = "http"
            path     = "/"
            interval = "2s"
            timeout  = "2s"
        }

      }
    }

  }
}
```
