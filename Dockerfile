FROM alpine
RUN apk add hugo git
WORKDIR /hugo
RUN hugo new site /hugo
RUN git clone https://github.com/yihui/hugo-xmin.git themes/hugo-xmin
ADD hugo.toml /hugo/hugo.toml
ADD content /hugo/content
CMD ["hugo", "serve", "--bind", "0.0.0.0"]
