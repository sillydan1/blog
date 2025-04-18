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

The very first thing to get is a server. This can either be the machine you're currently using if you don't want
to mess around on the public internet, or it could be an actual desktop you have set up with a public IP. Or
it could be a VPS (Virtual Private Server) - which is just a fancy word for a "cloud computer" that someone
else hosts and powers, and you just get an SSH connection to it. Any VPS provider will work, but [digital
ocean](https://www.digitalocean.com/) or [linode](https://www.linode.com/) are very affordable and easy to use
VPS providers. As long as you get a VPS and avoid a *webhotel*, you should be fine (side note: web hotels are a
scam and you shouldn't ever use them - especially not if you're tech-savvy enough to read this blog).

Once you have your server, [install](https://docs.docker.com/engine/install/) docker on it. Preferably the latest
version.

## Traefik and Portainer

Traefik is a load balancer / application proxy that makes it easy for you to route network traffic into your various
services on your server. By using traefik, you can have multiple docker containers, each providing their own service on
a single server, and traefik just routes user traffic based on the URL request, or ports used.

Portainer is a web-based docker container management GUI (Graphical User Interface) - if you've tried Docker Desktop,
think if portainer as a web-based version of that.

Getting traefik and portainer up and runinng is done by creating a new `docker-compose.yml` file on your server
and adding them as individual services. Just to keep things tidy, you should make a directory for all you are
going to do here. Do the following on your server.

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

It might be a good idea to initialize the `config` directory as a (local) `git` project. That way you will always have
a history of what you have been done, and what you did when you (inevitably) break things. This I will leave up to you
though (you should gitignore the `portainer-data` directory, since that's managed by portainer and may contain a bunch
of stuff you don't want).

Inside the new `docker-compose.yml` file, you should put the following content. Simply open the file using your favorite
terminal text editor and paste the following. Note! Don't start the stack yet - we still need to configure a bunch of
things.

```yaml
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
    environment:
      - "CF_DNS_API_TOKEN="  # ADD YOUR OWN DNS API TOKEN HERE
      - "CF_ZONE_API_TOKEN="  # ADD YOUR OWN DNS API TOKEN HERE

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
various configuration directories to their respective services.

If you haven't used `traefik` before, you might be scratching your head on the `labels` that we set on each of the
services. This is just how you configure services to integrate into traefik, enabling you to route your various
containers to various subdomains, integrate middle-wares such as forcing HTTPS and setting load-balancer settings etc.

The `CF_DNS_API_TOKEN` and `CF_ZONE_API_TOKEN` tokens are our cloudflare API keys. If you're using a different DNS
provider, you should check the [traefik documentation](https://doc.traefik.io/traefik/https/acme/#providers) to see if
your provider is supported, and change the environment variable names accordingly.

Since the configuration directories are currently empty, the setup won't work yet. Let's add the traefik configuration
files first:

```sh
cd ~/config/traefik-data
mkdir -p configurations
touch traefik.yml
touch configurations/dynamic.yml
```

The `traefik.yml` file contains your general traefik configuration. This is where you register certificates, enforce
HTTPS and set general settings. The content we're interested in having is the following:

```yaml
api:
  dashboard: true

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
  websecure:
    address: ":443"
    http:
      middlewares:
        - secureHeaders@file
      tls:
        certResolver: letsencrypt

certificatesResolvers:
  letsencrypt:
    acme:
      email: your-email-here
      storage: acme.json
      keyType: EC384
      dnsChallenge:
        provider: cloudflare
        delayBeforeCheck: 0

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
  file:
    filename: /configurations/dynamic.yml
```

The first `api` section is pretty self-explanatory enables the web-ui dashboard. You can choose not to do
this if you don't want the traefik web dashboard. The `entryPoints` section is a bit more interesting. This
is where we enforce that all HTTP web-requests on port `80` will be redirected to port `443` using transport
layer security (TLS). You might notice that we specifically mention `letsencrypt` here, this leads us
to the `certificatesResolvers` section. Since I am using [cloudflare](https://www.cloudflare.com/)
as my DNS (Domain Name Service) provider, I can also use them as my TLS certificate provider as
they provide this service. This is a complex topic and if you're interested, I recommend reading
[this](https://blog.cloudflare.com/introducing-automatic-ssl-tls-securing-and-simplifying-origin-connectivity/)
blog post by cloudflare themselves. Boiling all this jargan down, we are just using cloudflare as a middleman to
help us get the little lock icon in the browser when someone visits our website(s). I've set the certificates to
automatically update, so I don't have to worry about it ever again.

The `providers` settings refer to where traefik can route internet traffic to. We simply register `docker` as a service
provider as well as the configurations we define in `configurations/dynamic.yml`. Let's take a look at the content of
that file.

```yaml
http:
  middlewares:
    secureHeaders:
      headers:
        sslRedirect: true
        forceSTSHeader: true
        stsIncludeSubdomains: true
        stsPreload: true
        stsSeconds: 31536000
    user-auth:
      basicAuth:
        users:
          - "administrator:<password>"  # ADD YOUR ADMIN PASSWORD HERE ()

tls:
  options:
    default:
      cipherSuites:
        - TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
        - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
        - TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
        - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
        - TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305
        - TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305
      minVersion: VersionTLS12
```

Starting in the `http.middlewares` section, we first register a TLS middleware that we call `secureHeaders` (note that
this is the middleware referred in `traefik.yml`) - skipping past the details, this middleware simply adds security
headers to each request. Our second middleware, `user-auth` is the authentication method to gain access to the traefik
dashboard. Here we set the username `username` and you should generate the password using the `htpasswd` command. This
command should be available through the `apache2-utils` package on ubuntu systems, and `extra/apache` on Arch. Simply
copy / paste the generated hashed password into your yaml file.

```sh
# -n = output to stdout -B = use bcrypt
# Make sure to replace 'administrator' if you want a different username
htpasswd -nB administrator
```

## Starting Everything

We should now have everything set up and ready for starting! Simply navigate to the `~/control` directory and start the
docker compose stack.

```sh
# Start the containers (detached)
docker compose up -d

# Follow along with the logs
docker compose logs -f
```

Hopefully there shouldn't be any errors, but if there are, make doubly sure that your TLS settings are set correctly,
as that's likely to be the thing to mess up (ask me how I know). If you need additional assistance, the [official
traefik docs](https://doc.traefik.io/traefik/) are a great resource. Portainer is fairly fool-proof, so I don't expect
that to cause you any problems.

## TODO
 - [ ] DNS records, ACME challenges, TXT records, Wildcard A records, CAA records - jesus there's so much shit I've forgotten

{{< centered image="/6616144.png" >}}

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
