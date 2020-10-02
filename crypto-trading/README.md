# Make some crypto trading

----
## What is Crypto-trading ?
> Simply use algorithm to play with cryto-currency.

I follow this tutorial : [fotozik.fr](https://www.fotozik.fr/trading-de-crypto-automatise-avec-freqtrade)

Documentations :

* [Basics](https://www.freqtrade.io/en/latest/bot-basics/)
* [Indicator](https://github.com/mrjbq7/ta-lib/blob/fff6182033e6ae48e31c99cd639c97077637672a/docs/index.md)


----
## Setup and play with freqtrade

Why freqtrade ? Maintened and opensource. That's all.

For the setup, let's assume we are in the crypto-trading folder (the same as the README)

1 - Retrieve and build all part of the project :

```
git clone --depth 1 git@github.com:freqtrade/freqtrade.git
git clone --depth 1 git@github.com:freqtrade/freqtrade-strategies.git
git clone --depth 1 git@github.com:freqtrade/frequi.git

ln ma_super_strategy.py freqtrade-strategies/user_data/strategies/ma_super_strategy.py
ln sample_strategy.py freqtrade-strategies/user_data/strategies/sample_strategy.py
```

3 - Setup the user-config with new-config :

```
docker-compose -f ft-docker-compose.yml run --rm freqtrade new-config --config user_data/config.json
? File user_data/config.json already exists. Overwrite?  Yes
? Do you want to enable Dry-run (simulated trades)?  Yes
? Please insert your stake currency: BTC
? Please insert your stake amount: 0.09
? Please insert max_open_trades (Integer or 'unlimited'): 3
? Please insert your desired timeframe (e.g. 5m): 1m
? Please insert your display Currency (for reporting): EUR
? Select exchange  binance
? Do you want to enable Telegram?  No
```

Then go to the `config.json` and replace the part related to `api_server` by

    "api_server": {
        "enabled": true,
        "listen_ip_address": "0.0.0.0",
        "listen_port": 8080,
        "verbosity": "error",
        "jwt_secret_key": "jwt_secret_key",
        "CORS_origins": ["http://localhost:8081", "http://127.0.0.1:8081"],
        "username": "username",
        "password": "password"
    },

Then run the docker-compose freqtrade :  `docker-compose -f ft-docker-compose.yml run --rm --service-ports --use-aliases freqtrade`

Test that the API work corretly : `docker-compose -f ft-docker-compose.yml run --rm --service-ports --use-aliases freqtrade-console bash -c "curl http://freqtrade:8080/api/v1/ping"` (should display `{"status":"pong"}`)

Update now the file `frequi/vue.config.js` and replace `http://127.0.0.1:8081` by `http://freqtrade:8080`

Then run the docker-compose frequi :  `docker-compose -f ft-docker-compose.yml run --rm --service-ports --use-aliases frequi`

On host : `open http://localhost:8081`

At this point, we've go freqtrade, an UI for freqtrade and some strategies. Now, let's try strategies :

5 - Download data to run the tests :

`docker-compose -f ft-docker-compose.yml run --rm freqtrade download-data --exchange binance --days 30`

5 - Let's test the `MaSuperStrategy.py` strategy : `docker-compose -f ft-docker-compose.yml run --rm freqtrade backtesting -s MaSuperStrategy --export trades`

6 - With the export, we can generate a graph for analysis : `docker-compose -f ft-docker-compose.yml run freqtrade plot-dataframe -s MaSuperStrategy`

7 - Let's compose some basic strategies :
```
docker-compose -f ft-docker-compose.yml run --rm freqtrade backtesting --strategy-list InformativeSample Strategy001 Strategy002 Strategy003 Strategy004 Strategy005 MaSuperStrategy --strategy-path /freqtrade/user_data/strategies
```

8 - Let's check berlinguyinca strategies :

```
docker-compose -f ft-docker-compose.yml run --rm freqtrade backtesting --strategy-list ADXMomentum ASDTSRockwellTrading AdxSmas AverageStrategy AwesomeMacd BbandRsi BinHV27 BinHV45 CCIStrategy CMCWinner ClucMay72018 CofiBitStrategy CombinedBinHAndCluc DoesNothingStrategy EMASkipPump Freqtrade_backtest_validation_freqtrade1 Low_BB MACDStrategy MACDStrategy_crossed MultiRSI Quickie ReinforcedAverageStrategy ReinforcedQuickie ReinforcedSmoothScalp Scalp Simple SmoothOperator SmoothScalp TDSequentialStrategy TechnicalExampleStrategy --strategy-path /freqtrade/user_data/strategies/berlinguyinca
```

KeyError with ReinforcedSmoothScalp => `dataframe['resample_sma']` become `dataframe.get('resample_sma')`
Error in SmoothOperator => `replace df = df.resample(str(int(interval[:-1]) * factor) + 'min', plotoschow=ohlc_dict)` become  `df = df.resample(str(int(interval[:-1]) * factor) + 'min').agg(ohlc_dict)` and comment `(dataframe['close'] > dataframe)`


Ok so BinHV45, ClucMay72018, CombinedBinHAndCluc, MACDStrategy_crossed seems interresting.

# TODO :
# Read the basics and learn notation & co
# Test Binance (check the warning on freqtrade page) Connect to it.
# Test hyperopts

# Follow the next part of fotozik : https://www.fotozik.fr/trading-de-crypto-automatise-avec-freqtrade-partie-2

# Docker reminder to clean everything
docker rm -f $(docker ps -a -q)
docker rmi -f $(docker images -a -q)
docker volume rm $(docker volume ls -q)
docker network rm $(docker network ls | tail -n+2 | awk '{if($2 !~ /bridge|none|host/){ print $1 }}')
