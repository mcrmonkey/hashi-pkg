FROM debian:latest
LABEL maintainer "ant <git@manchestermonkey.co.uk>"

RUN apt-get update -qq && \
    apt-get upgrade -qq && \
	apt-get install -qq vim wget curl ruby ruby-dev build-essential reprepro wget curl vim rpm

RUN gem install fpm

RUN mkdir /output

ADD ./prep-pkg.sh /

CMD ["/prep-pkg.sh"]
