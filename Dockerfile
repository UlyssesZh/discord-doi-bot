FROM ruby:4.0.5
WORKDIR /app
COPY . .

RUN bundle install

ENTRYPOINT [ "bundle", "exec", "./main.rb" ]
