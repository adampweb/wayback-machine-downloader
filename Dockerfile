FROM ruby:3.4.5-alpine
USER root
WORKDIR /build

COPY Gemfile /build/
COPY *.gemspec /build/

RUN bundle config set jobs "$(nproc)" \
    && bundle config set without 'development test' \
    && bundle install

COPY . /build

WORKDIR /
ENTRYPOINT [ "/build/bin/wayback_machine_downloader" ]
