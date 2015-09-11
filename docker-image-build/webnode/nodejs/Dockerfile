##################################################################################
## 
## VERSION		:	0.0.1
## DATE			:	07Sep2015
##
## DESCRIPTION	:	"This image installs ssh, updates centos6.6 and basic hadoop components daemon on base centos:6.6 image" Vendor="Miztiik Corp" Version="1.0"
##
## Ref [1]		:	https://docs.docker.com/examples/running_ssh_service/
##
##################################################################################
FROM alpine
MAINTAINER mystique <b4wt@quantumfoam.uni.me>

# Add the tar file of the web site 
RUN apk update && apk add nodejs && rm -rf /var/cache/apk/* && mkdir /data

WORKDIR /data

EXPOSE 80

ENTRYPOINT [ "sh" ]
CMD [""]