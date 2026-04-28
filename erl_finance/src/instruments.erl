-module(instruments).
 -module(instruments).
 -export([
     stock/1,
     bond/2,
     rate/1,
     terminal/1,
     path/1,
     constant/1,
     binary/2,
     diff/2,
     max_of/1,
     min_of/1,
     add/2,
     choice/2
 ]).

%% Constructors to create our "Objects"
new_stock(Symbol, Price) ->
    #{type => stock, symbol => Symbol, price => Price}.

new_bond(Type, Notional, Rate) ->
    #{type => bond, bond_type => Type, notional => Notional, rate => Rate}.

%% The "value" function uses Pattern Matching (like a Polymorphic switch)
value(#{type := stock, price := P}) -> P;
value(#{type := bond, notional := N, rate := R}) -> N * (1 + R);
value(#{type := derivative, underlying := U}) -> value(U) * 0.1; %% Example logic
value(_) -> 0.

%% The "risk" function
risk(#{type := stock}) -> 0.8;
risk(#{type := bond}) -> 0.2;
risk(_) -> 0.5.