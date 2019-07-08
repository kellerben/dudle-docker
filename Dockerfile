# preparations:
# git clone https://github.com/kellerben/dudle.git cgi
#
# build:
# docker build -t my-dudle .
#
# run:
# docker run -it -p 8888:80 -v /srv/dudle-backup:/backup:Z  --rm --name my-running-dudle my-dudle

FROM centos:7

RUN yum -y install \
	httpd\
	ruby\
	ruby-devel\
	git\
	rubygems\
	gcc\
	make\
	epel-release\
	wget\
	libxml2-devel\
	&& yum clean all
RUN gem install gettext iconv ratom

CMD [ "/usr/local/bin/start.sh" ]

COPY ./scripts/container/ /usr/local/bin/

COPY ./cgi/ /var/www/dudle/

RUN sed -ri \
		's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g; \
		s!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g;' \
		/etc/httpd/conf/httpd.conf
COPY ./conf/httpd/dudle.conf /etc/httpd/conf.d/

COPY ./skin/css/ /var/www/dudle/css/
COPY ./skin/conf/ /var/www/dudle/

RUN chmod -R go-w /var/www/dudle
RUN chgrp apache /var/www/dudle
RUN chmod 775 /var/www/dudle

RUN cd /var/www/dudle && \
    for i in locale/?? locale/??_??; do \
        wget -O $i/dudle.mo https://dudle.inf.tu-dresden.de/locale/`basename $i`/dudle.mo; \
    done

