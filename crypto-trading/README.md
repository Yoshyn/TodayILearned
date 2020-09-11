# Make some crypto trading

----
## What is Crypto-trading ?
> Simply use algorithm to play with cryto-currency.

I follow this tutorial : [fotozik.fr](https://www.fotozik.fr/trading-de-crypto-automatise-avec-freqtrade)

see [Sourceforge](https://sourceforge.net/projects/crunch-wordlist/)

----
## Setup and play with freqtrade

Why freqtrade ? Maintened and opensource. That's all.

For the setup, let's assume we are in the crypto-trading folder (the same as the README)

1 - Retrieve and build the project :

```
git clone --depth 1 git@github.com:freqtrade/freqtrade.git
git clone --depth 1 git@github.com:freqtrade/freqtrade-strategies.git
ln MaSuperStrategie.py freqtrade-strategies/user_data/strategies/MaSuperStrategie.py
docker build -f ft-local.Dockerfile -t freqtradeorg/freqtrade:local freqtrade
docker build -f ft-local-dev.Dockerfile -t freqtradeorg/freqtrade:local-dev freqtrade
```

2 - Just go into freqtrade `cd freqtrade`

3 - Setup the user-config with new-config :

```
docker-compose -f $(pwd)/../ft-docker-compose.yml run --rm freqtrade new-config --config user_data/config.json
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

5 - Download data to run the tests :

`docker-compose -f $(pwd)/../ft-docker-compose.yml run --rm freqtrade download-data --exchange binance --days 30`

5 - Let's test the `MaSuperStrategie.py` strategy : `docker-compose -f $(pwd)/../ft-docker-compose.yml run --rm freqtrade backtesting -s MaSuperStrategie --export trades`

6 - With the export, we can generate a graph for analysis : `docker-compose -f $(pwd)/../ft-docker-compose.yml run freqtrade plot-dataframe -s MaSuperStrategie`

7 - Let's compose some basic strategies :

docker-compose -f $(pwd)/../ft-docker-compose.yml run --rm freqtrade backtesting --strategy-list InformativeSample Strategy001 Strategy002 Strategy003 Strategy004 Strategy005 MaSuperStrategie --strategy-path /freqtrade/user_data/strategies/berlinguyinca

8 - Let's check berlinguyinca strategies :

docker-compose -f $(pwd)/../ft-docker-compose.yml run --rm freqtrade backtesting --strategy-list ADXMomentum ASDTSRockwellTrading AdxSmas AverageStrategy AwesomeMacd BbandRsi BinHV27 BinHV45 CCIStrategy CMCWinner ClucMay72018 CofiBitStrategy CombinedBinHAndCluc DoesNothingStrategy EMASkipPump Freqtrade_backtest_validation_freqtrade1 Low_BB MACDStrategy MACDStrategy_crossed MultiRSI Quickie ReinforcedAverageStrategy ReinforcedQuickie ReinforcedSmoothScalp Scalp Simple SmoothOperator SmoothScalp TDSequentialStrategy TechnicalExampleStrategy --strategy-path /freqtrade/user_data/strategies/berlinguyinca

KeyError with ReinforcedSmoothScalp => `dataframe['resample_sma']` become `dataframe.get('resample_sma')`
Error in SmoothOperator => `replace df = df.resample(str(int(interval[:-1]) * factor) + 'min', plotoschow=ohlc_dict)` become  `df = df.resample(str(int(interval[:-1]) * factor) + 'min').agg(ohlc_dict)` and comment `(dataframe['close'] > dataframe)`


Ok so BinHV45, ClucMay72018, CombinedBinHAndCluc, MACDStrategy_crossed seems interresting.

# TODO :

# Setup the UI : https://github.com/freqtrade/frequi

# Follow the next part of fotozik : https://www.fotozik.fr/trading-de-crypto-automatise-avec-freqtrade-partie-2
