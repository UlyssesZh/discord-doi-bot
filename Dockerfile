FROM ruby:3.4.2
WORKDIR /app
COPY . .

RUN bundle install

ENTRYPOINT [ "/app/main.rb" ]
