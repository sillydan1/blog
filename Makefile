demo:
	docker build -t wip .
	docker run --rm -it -p 8080:8080 wip hugo serve --bind 0.0.0.0 --port 8080
