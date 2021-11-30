FROM ruby:latest

ENV APP_PATH /usr/src/app
RUN mkdir -p /usr/src/app

COPY entrypoint.sh $APP_PATH/entrypoint.sh
COPY config.ru $APP_PATH/config.ru
COPY application.rb $APP_PATH/application.rb
RUN chmod +x $APP_PATH/entrypoint.sh

WORKDIR $APP_PATH

EXPOSE 8080

ENTRYPOINT ["./entrypoint.sh"]

CMD ["ruby", "config.ru"]