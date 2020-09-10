from freqtrade.strategy.interface import IStrategy
from pandas import DataFrame
import talib.abstract as ta
import freqtrade.vendor.qtpylib.indicators as qtpylib

class MaSuperStrategie(IStrategy):
    # Parameters Mandatory
    stoploss = -0.05 # Fermeture de l'ordre si perte de 5%

    ticker_interval = '1m' # Nous jouons avec les chandeliers de 1 minutes

    # Fermeture de l'ordre si gain de 1%
    minimal_roi = { "0": 0.015 }


    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        # Ajout du RSI
        dataframe['rsi'] = ta.RSI(dataframe, timeperiod=14)

        # Définition de l'indicateur Bollinger
        bollinger = qtpylib.bollinger_bands(qtpylib.typical_price(dataframe), window=20, stds=2)
        # Ajout de la bande supérieure
        dataframe['bb_lowerband'] = bollinger['lower']

        return dataframe

    def populate_buy_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe.loc[
            (
                # Lorsque le RSI est inférieur à 30
                (dataframe['rsi'] < 30) &
                # Lorsque la clôture du cours est sous la bande inférieure
                (dataframe['close'] < dataframe['bb_lowerband'])
            ),
            'buy'] = 1
        return dataframe

    def populate_sell_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe.loc[
            (
                # Sortie lorsque le RSI est supérieur à 70
                (dataframe['rsi'] > 50)
            ),
            'sell'] = 1
        return dataframe
