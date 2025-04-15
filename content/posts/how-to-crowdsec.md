+++
date = '2025-04-15'
draft = true
title = "How to Set Up Crowdsec"
tags = ["howto", "tutorial", "web", "securoty"]
categories = ["technical"]
+++
## Crowdsec

> NOTE: This configuration blocks *many* varieties of clients and services. You might want to whitelist your own ISP and
> / or your own IP ranges (perhaps even your entire country if you're trusting enough) in case your own services and
> homebrew experiments gets banned.

Short for [crowdsecurity](https://www.crowdsec.net/), crowdsec is a community effort to bring auto-banning security to
the masses, and it's surprisingly easy to set up. You just have to understand how the thing works.


I noticed that I am getting a lot of suspicious traffic on my gitea instance. Usernames such as `log4j` and `thomad`
from china and bulgaria. Yea. Let's enable some fucking security.
Fuck I hate that I have to do this, but I guess people will be assholes.

After [this](https://www.youtube.com/watch?v=-GxUP6bNxF0), the banhammer came down with the might of zeus. Now no-one
gets access. Not even me. I tried to do some country-code whitelisting, but that was a bit of a dud. I'm tired now.
Will look at it tomorrow.

Okay! I seem to have it working now! That was an adventure. Will elaborate when I get back home.

Okay, There's multiple "things" to a crowdsec setup. Crowdsec (the non-paid cloud solution) consists of:
- The core crowdsec security engine (`crowdsecurity/crowdsec` container image)
    - Does the "detection" and hardcore logic and makes decisions.
- The bouncer (`fbonalair/traefik-crowdsec-bouncer:latest` container image in my case)
    - Enforces the decisions.
    - There are multiple different "types" of bouncers. I just use the forwardAuth type, as that is the most straight
      forward one. Especially when combined with traefik.

### Concepts

In short, there are only a couple of concepts you should know in order to *use* crowdsec. This is 
Feel free to skip these if you
don't care for now, and just want something up and running.

 - Acquisitions
   - In order for `crowdsec` to know *what* and *where* to look for potential intruders, threats etc. You must tell it
   in the form of *acquisition* configurations. The easiest thing to do is to just give `crowdsec` access to your docker
   logs and traefik logs - this is excactly what we're aiming to do.
 - Parsers
 - Bucket Overflow
 - Bouncers

Note that the core crowdsec security engine should be part of the core traefik/portainer deployment because it will
need some elevated privileges. The traefik service should also register some middlewares, so it can't be part of the
portainer managed containers / stacks.

When using Traefik, make sure to add the docker labels that enable traefik trafficing to the containers:

```yaml
# For the new containers.
labels:
  - traefik.enable=true
  - traefik.docker.network=proxy
  - traefik.http.routers.traefik-bouncer.entrypoints=websecure
```

## "easy"


This shit was not easy to set up. But it is easy to maintain. Keep a "new"/"learning" mind, and all should be fine.

## Configuring the Bouncer

Also called "Remediation"
I am using the traefik bouncer, that is using
[forwardAuth](https://doc.traefik.io/traefik/middlewares/http/forwardauth/) to check if an IP is blocked or not.

Configure the container in docker compose and afterwards, you should introduce the traefik middleware in the dynamic
and static configuration, like so:

```yaml
# dynamic traefik config
http:
middlewares:
traefikBouncer:
forwardauth:
address: http://traefik-bouncer:8080/api/v1/forwardAuth
trustForwardHeader: true
```

```yaml
# static traefik config
entryPoints:
http:
address: ":80"
http:
middlewares:
- traefikBouncer@file
https:
address: ":443"
http:
middlewares:
- traefikBouncer@file
```

If you have (I do) some other names for the `address: ":443"` and `":80"` middlewares, don worry, just add the
`traefikBouncer@file` to the list of middlewares and you should be good.

You will have to register your bouncer through the `cscli` as well:

```sh
docker exec crowdsec cscli bouncers list
docker exec crowdsec cscli bouncers add traefikBouncer
```

This should give you an API key. Place it in the environment variable `CROWDSEC_BOUNCER_API_KEY: <your-key-here>`.
Additionally, you should add the `CROWDSEC_AGENT_HOST: crowdsec:8080` environment variable (assuming the crowdsec
docker _service_ is called `crowdsec`) - the port is standard and you don't need to portmap or expose anything btw.

### Crowdsec Core Security Engine Configuration

In order for the crowdsec security engine to be able to detect intruders, it needs access to the logs of the other
containers on the server. To do this, you can just volume mount: `/var/run/docker.sock:/var/run/docker.sock:ro` and
then 

Check out [https://app.crowdsec.net/hub/configurations](https://app.crowdsec.net/hub/configurations) if there are logparsers available for the service you want
to integrate.

#### Acquisitions

In the `acquis.d` directory (volume mapped into the `crowdsec` container to `./acquis.d:/etc/crowdsec/acquis.d`),
you should add YAML files for each source you want the crowdsec engine to scan for criminals and other scum:

```txt
acquis.d/
├── gitea.yaml
└── traefik.yaml
```

File Contents:

```yaml
# traefik.yaml
filenames:
- /var/log/traefik/*
labels:
type: traefik
```

```yaml
# gitea.yaml
source: docker
container_name:
- gitea
labels:
type: gitea
```

`traefik.yml` is a `filename` based acquisition file, meaning you need to configure the `traefik` container to
output access and system logs into a directory that is volume-mapped so that it's available to the crowdsec
container (`traefik-logs:/var/log/traefik/:ro` and associated `traefik-logs:/var/log/traefik/` on traefik).

The acquisition file for the `gitea` service is using the `docker` source. So it'll read the `docker logs`. The
cool thing about this, is that you dont have to do any extra configuration on the gitea side.

To configure `traefik` to output logs into a file (default it just outputs to stdout/stderr for no-one to read),
add the following to your static config (`traefik.yml`) - make sure to `docker compose up -d --force-recreate`
every time you edit the config (and want to apply the changes):

```yaml
# ... at the end of traefik.yml
log:
level: INFO
filePath: /var/log/traefik/traefik.log
accessLog:
filePath: /var/log/traefik/access.log
```

Also, in docker compose file, install some collections:

```yaml
# in crowdsec container spec
environment:
GID: "$(GID-1000)"
COLLECTIONS: "crowdsecurity/linux crowdsecurity/traefik crowdsecurity/whitelist-good-actors LePresidente/gitea"
```

#### Geofenching

You might have lost the bouncer - check with `docker exec crowdsec cscli bounders list`.

I am hosting some services that may produce some false-flags by crowdsec, so I will be whitelisting my country. To
do this, we need to register a country-code whitelist 
[postoverflow](https://docs.crowdsec.net/docs/whitelist/create_postoverflow/) in the `postoverflows` directory,
which is volume mapped `./postoverflows:/etc/crowdsec/postoverflows/`:

```yaml
# postoverflow/s01-whitelist/sc-countries-whitelist.yaml
name: my/whitelist
description: Whitelist trusted regions
whitelist:
reason: Whitelisted country
expression:
- "evt.Enriched.IsoCode == 'DK'"  # NO! Not anymore!
```

Note that the data is not "enriched" with the IsoCode yet. You need to install the `geoip-enrich` thing:

```sh
docker exec crowdsec cscli parsers install crowdsecurity/geoip-enrich
```

This solution is not very sophisticated, so I might change this to something less "sledgehammer"-y in the future.
