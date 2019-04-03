FROM ruby:2.2.2

RUN mkdir -p /var/app
WORKDIR /var/app

COPY . .

RUN bundle install
