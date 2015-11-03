FROM ubuntu:14.04

RUN apt-get -qq update

RUN apt-get update && apt-get install -y --no-install-recommends openjdk-7-jre-headless tar curl && apt-get autoremove -y && apt-get clean

ENV JRUBY_VERSION 1.7.19
ENV GEM_HOME /opt/jruby-$JRUBY_VERSION
ENV GEM_PATH $GEM_HOME

RUN curl http://jruby.org.s3.amazonaws.com/downloads/$JRUBY_VERSION/jruby-bin-$JRUBY_VERSION.tar.gz | tar xz -C /opt

ENV PATH /opt/jruby-$JRUBY_VERSION/bin:$PATH

RUN echo gem: --no-document >> /etc/gemrc

RUN apt-get -qqy install libreadline-dev libssl-dev zlib1g-dev build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev

RUN apt-get install -y imagemagick libmagick++-dev libmagic-dev && apt-get clean
RUN apt-get install -y libmagickcore-dev





# ENV BUNDLE_PATH $GEM_HOME

VOLUME ['/api']
WORKDIR /api

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh


EXPOSE 8080 4447 9990 8000/tcp

CMD /sbin/entrypoint.sh

# CMD ["torquebox", "start", "-p", "8000", "-b", "0.0.0.0"]
# CMD ["bundle", "exec", "rackup", "-p", "8000", "-o", "0.0.0.0"]