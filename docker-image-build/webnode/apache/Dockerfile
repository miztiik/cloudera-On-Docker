FROM httpd
MAINTAINER mystique <b4wt@quantumfoam.uni.me>

# Add the tar file of the web site 
ADD mysite.tar /tmp/

# Docker automatically extracted. So move files to web directory
RUN mv /tmp/mysite/* /var/www/html

EXPOSE 80

ENTRYPOINT [ "/usr/sbin/httpd" ]
CMD [ "-D", "FOREGROUND" ]