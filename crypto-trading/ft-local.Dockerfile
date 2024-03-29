# docker build -f Dockerfile.local -t freqtradeorg/freqtrade:local .
FROM python:3.8.5-slim-buster

RUN apt-get update \
    && apt-get -y install curl git build-essential libssl-dev sqlite3 \
    && apt-get clean \
    && pip install --upgrade pip

# Prepare environment
RUN mkdir /freqtrade
WORKDIR /freqtrade

# Install TA-lib
COPY build_helpers/* /tmp/
RUN cd /tmp && /tmp/install_ta-lib.sh && rm -r /tmp/*ta-lib*

ENV LD_LIBRARY_PATH /usr/local/lib

# Install dependencies
COPY requirements.txt requirements-hyperopt.txt /freqtrade/
COPY requirements-dev.txt requirements-plot.txt /freqtrade/
RUN pip install numpy --no-cache-dir \
  && pip install -r requirements-dev.txt --no-cache-dir
RUN pip install git+https://github.com/freqtrade/technical

# Install and execute
COPY . /freqtrade/
RUN pip install -e . --no-cache-dir
ENTRYPOINT ["freqtrade"]
# Default to trade mode
CMD [ "trade" ]
