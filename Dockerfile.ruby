FROM ruby:3.1.0-alpine

RUN apk update  && apk upgrade && apk add --update --no-cache \
  build-base tzdata bash htop

WORKDIR /opt/app

COPY Gemfile* ./

RUN gem install bundler
RUN bundle install

COPY . .
