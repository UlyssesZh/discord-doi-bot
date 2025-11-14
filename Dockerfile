FROM ruby:3.4.2
WORKDIR /app
COPY . .

RUN bundle install

ENTRYPOINT [ "bundle", "exec", "./main.rb" ]
