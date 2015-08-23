##################################################################################
## 
## VERSION		:0.0.1
## DATE			:24Aug2015
##
## DESCRIPTION	:"This image build python for a simple http server based on python which uses virtualbox shared folders destination as web root"
##
## Ref [1]		:https://github.com/gliderlabs/docker-alpine
##
##################################################################################
FROM alpine:latest

RUN apk add --update python \
&& rm -rf /var/cache/apk/*

CMD ["/env/bin/python", "main.py"]

