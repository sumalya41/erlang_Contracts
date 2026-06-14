-module(market_calculations).
-export([calculate_volatility/2, calculate_volatility/3, simple_moving_average/2, exponential_moving_average/2]).

%% Calculate volatility using standard deviation of returns
calculate_volatility(Prices, Period) ->
    calculate_volatility(Prices, Period, daily).

calculate_volatility(Prices, Period, Frequency) ->
    case length(Prices) < Period of
        true -> 0;
        false ->
            RecentPrices = lists:sublist(Prices, Period),
            Returns = calculate_returns(RecentPrices),
            MeanReturn = calculate_mean(Returns),
            Variance = calculate_variance(Returns, MeanReturn),
            StdDev = math:sqrt(Variance),
            case Frequency of
                daily -> StdDev;
                weekly -> StdDev * math:sqrt(5);
                monthly -> StdDev * math:sqrt(21);
                yearly -> StdDev * math:sqrt(252)
            end
    end.

%% Calculate returns (percentage change)
calculate_returns([_]) -> [];
calculate_returns([Prev, Current | Rest]) ->
    [((Current - Prev) / Prev) | calculate_returns([Current | Rest])].

%% Calculate mean of a list
calculate_mean(List) ->
    Sum = lists:sum(List),
    Length = length(List),
    case Length > 0 of
        true -> Sum / Length;
        false -> 0
    end.

%% Calculate variance
calculate_variance(List, Mean) ->
    SquaredDiffs = [math:pow(X - Mean, 2) || X <- List],
    calculate_mean(SquaredDiffs).

%% Simple Moving Average
simple_moving_average(Prices, Period) ->
    case length(Prices) >= Period of
        true ->
            Recent = lists:sublist(Prices, Period),
            calculate_mean(Recent);
        false ->
            calculate_mean(Prices)
    end.

%% Exponential Moving Average
exponential_moving_average(Prices, Period) ->
    Multiplier = 2 / (Period + 1),
    calculate_ema(Prices, Period, Multiplier, simple_moving_average(Prices, Period)).

calculate_ema([_], _, _, EMA) -> EMA;
calculate_ema([Current, Prev | Rest], Period, Multiplier, EMA) when length([Prev | Rest]) >= Period ->
    NewEMA = (Current * Multiplier) + (EMA * (1 - Multiplier)),
    calculate_ema([Prev | Rest], Period, Multiplier, NewEMA).