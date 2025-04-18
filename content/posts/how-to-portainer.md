+++
date = '2025-04-14'
draft = true
title = "How to Host Docker Containers Easily in The Cloud"
tags = ["howto", "tutorial", "web"]
categories = ["technical"]
+++

In this post, we will be going over how to set up a [portainer](https://www.portainer.io/) managed docker environment,
and how to use it. This is ideal if you want to host a personal website, a [blog](/posts/how-to-blog), a personal
[github](git.gtz.dk) or whatever your development heart desire.
If you choose to follow along, by the end of it, you will have an environment where you can just add or remove docker
based services at a whim using a nice web-based interface.

I assume that you already know about `docker` and `docker compose` yaml syntax. If you don't, may I recommend the
wonderful official [docker tutorial](https://docs.docker.com/get-started/workshop/) - once you're done with that come
back here. Or just read on and roll with the punches.

Oh yea, you should also have good knowledge and experience working on GNU/Linux systems, as you'll be doing a lot of
management and interaction with the terminal both during the setup process and during maintenance.

## Server

The very first thing to get is a server. This can either be the machine you're currently using if you don't want to mess
around on the public internet, or it could be an actual desktop you have set up with a public IP. Or it could be a VPS
(Virtual Private Server) - which is just a fancy word for a "cloud computer" that someone else hosts and powers, and you
just get an SSH connection to it. Any VPS provider will work, but [digital ocean](https://www.digitalocean.com/) is very
affordable and easy to use. As long as you get a VPS and avoid a *webhotel*, you should be fine (side note: webhotels
are a scam and you shouldn't ever use them - especially not if you're tech-savvy enough to read this blog).

Once you have your server, [install](https://docs.docker.com/engine/install/) docker on it. Preferably the latest
version.

## Traefik and Portainer

The very first thing to get done is set up portainer and traefik. This is done by creating a new `docker-compose.yml`
file on your server. Just to keep things tidy, you should make a directory for all you are going to do here.

```sh
# Make the config directory in your $HOME dir - this is where 
# we'll be working throughout the tutorial. If not specified
# otherwise, you should only be editing files inside this directory.
mkdir -p ~/config
mkdir -p ~/config/traefik-data
mkdir -p ~/config/portainer-data
cd ~/config

# Create an empty yaml file
touch docker-compose.yml
```

It might be a good idea to initialize the `control` directory as a (local) `git` project. That way you will always have
a history of what you have been done, and what you did when you (inevitably) break things. This I will leave up to you
though (probably gitignore the `portainer-data` directory).

Inside the new `docker-compose.yml` file, you should put the following content (open the file using your favorite
terminal text editor).

```yaml
# docker-compose.yml
services:
  traefik:
    image: traefik:latest
    container_name: traefik
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    networks:
      - proxy
    ports:
      - 80:80
      - 443:443
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik-data/traefik.yml:/traefik.yml:ro
      - ./traefik-data/acme.json:/acme.json
      - ./traefik-data/configurations:/configurations
    labels:
      - traefik.enable=true
      - traefik.docker.network=proxy
      - traefik.http.routers.traefik-secure.entrypoints=websecure
      - traefik.http.routers.traefik-secure.rule=Host(`traefik.example.com`)
      - traefik.http.routers.traefik-secure.service=traefik
      - traefik.http.routers.traefik-secure.middlewares=user-auth@file
      - traefik.http.routers.traefik-secure.service=api@internal

  portainer:
    image: portainer/portainer-ce:alpine
    container_name: portainer
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    networks:
      - proxy
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./portainer-data:/data
    labels:
      - traefik.enable=true
      - traefik.docker.network=proxy
      - traefik.http.routers.portainer-secure.entrypoints=websecure
      - traefik.http.routers.portainer-secure.rule=Host(`portainer.example.com`)
      - traefik.http.routers.portainer-secure.service=portainer
      - traefik.http.services.portainer.loadbalancer.server.port=9000

networks:
  proxy:
    external: true
```

Whew! That's a lot. Let's break it down. We define two services `traefik` and `portainer`. Starting with the things that
are common to both of them, we set the initial niceties, such as the `container_name`, restart policy, security options
and set their shared network to be the externally defined `proxy` network. Both services need (read-only) access to the
system time for various reasons, so we volume mount `/etc/localtime` to their respective internal `/etc/localtime`. They
also both need access to the system docker socket, so we also volume mount that in (again, read-only). Then we map the
various configuration files in (we will soon make these).

If you haven't used `traefik` before, you might be scratching your head on the `labels` that we set on each of the
services. This is how you configure services to integrate into traefik, enabling you to route your various containers to
various subdomains, integrate middlewares such as forcing HTTPS and setting load-balancer settings etc.

Let's add the configuration files, shall we?

## Keycloak

## TODOs
 - [ ] 2FA the control dashboards through keycloak
 - [x] geoblocking the control dashboards
 - [ ] start the article with a demo of what we'll be making
 - MAYBE:
   - [ ] portainer introduction (maybe)
   - [ ] traefik introduction (maybe)
   - [ ] add a "skip if you already know portainer and traefik"


```yaml
services:
  postgresql:
    image: postgres:16
    environment:
      - POSTGRES_USER=keycloak
      _ POSTGRES_DB=keycloak
      - POSTGRES_PASSWORD=secret
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - keycloak


  keycloak:
    image: quay.io/keycloa/keycloak:22
    restart: always
    command: start
    depends_on:
      - postgresql
    environment:
      # traefik handles ssl
      - KC_PROXY_ADDRESS_FORWARDING=true
      - KC_HOSTNAME_STRUCT=false
      - KC_HOSTNAME=keycloak.gtz.dk
      - KC_PROXY=edge
      - KC_HTTP_ENABLED=true
      # connect to the postgres thing
      - DB=keycloak
      - DB_URL='jdbc:postgresql://postgres:5432/postgresql?ssl=allow'
      - DB_USERNAME=keycloak
      - DB_PASSWORD=secret
      - KEYCLOAK_ADMIN=admin
      - KEYCLOAK_ADMIN_PASSWORD=admin
    networks:
      - proxy
      - keycloa
    labels:
      - "traefik.enable=true"
      - port=8080

networks:
  proxy:
    external: true
  keycloak:
```

{{< centered image="/6616144.png" >}}
