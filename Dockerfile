FROM ruby:3.4.5-alpine
USER root
WORKDIR /build

COPY Gemfile /build/
COPY *.gemspec /build/

RUN bundle config set jobs "$(nproc)" \
    && bundle install

COPY . /build

WORKDIR /build
ENTRYPOINT [ "/build/bin/wayback_machine_downloader", "--directory", "/build/websites" ]
