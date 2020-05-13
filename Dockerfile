FROM ruby:2.7.0-alpine3.11

RUN apk add --no-cache \
  build-base \
  curl-dev \
  postgresql-dev \
  nodejs \
  yarn \
  nano

WORKDIR /app
COPY Gemfile Gemfile.lock ./

RUN bundle config set deployment 'true'
RUN bundle install --jobs $(nproc)
COPY . ./

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
