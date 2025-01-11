+++
date = '2024-12-04'
draft = true
title = "How to Host Docker Containers Easily in The Cloud"
tags = ["howto", "tutorial", "web"]
categories = ["technical"]
+++

In this post, we will be going over how to set up a [portainer]() managed docker environment, and how to use it.
This is ideal if you want to host a personal website, a [blog](/posts/how-to-blog), a personal [github](git.gtz.dk) or whatever your development heart desire.
If you choose to follow along, by the end of it, you will have an environment where you can just add or remove docker based services. It's even quite secure!

## Portainer

## Traefik

## Keycloak

## Automatic backups

## TODOs
 - [ ] 2FA the control dashboards through keycloak
 - [ ] geoblocking the control dashboards
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
