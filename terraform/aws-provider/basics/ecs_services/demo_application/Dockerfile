FROM ruby:3-alpine

ENV APP_PATH /usr/src/app

RUN apk add --update-cache \
  build-base \
  tzdata \
  openssl \
  curl \
  ca-certificates \
  postgresql-client \
  bash \
  && rm -rf /var/cache/apk/* \
  && mkdir -p $APP_PATH

COPY entrypoint.sh $APP_PATH/entrypoint.sh
COPY config.ru $APP_PATH/config.ru
COPY application.rb $APP_PATH/application.rb
COPY schema.sql $APP_PATH/schema.sql
RUN chmod +x $APP_PATH/entrypoint.sh

WORKDIR $APP_PATH

EXPOSE 8080

ENTRYPOINT ["./entrypoint.sh"]

CMD ["ruby", "config.ru"]