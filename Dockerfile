FROM ruby:2.5

RUN mkdir -p /var/app
WORKDIR /var/app

COPY . .

RUN bundle install
