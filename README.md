# gtz blog
An opinionated blog.
I write posts about technology and other interests that I have.

To iterate locally:
```sh
docker build -t wip .
docker run --rm -it -p 8080:8080 wip hugo serve --bind 0.0.0.0 --port 8080
```

## Things I want to write

### Opinion Pieces
 - [ ] Clean Architecture is stupid - dependency injection is king
 - [ ] Neorg is bad, actually - ?? is king

### Digital Soverignty
 - [x] how to host a blog
 - [ ] how to securely "self-host" using a VPS, portainer and traefik
 - [ ] how to configure neomutt
 - [ ] how to securely host a mail server

### Old sillyblog
 - [x] Avr memory model
 - [x] similarity graph
