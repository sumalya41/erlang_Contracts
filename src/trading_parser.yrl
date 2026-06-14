Nonterminals command action_clause condition_clause condition_clause condition_clause condition expression comparison ma_condition ema_condition volatility_condition.

Terminals action shares of when_kw price volume volatility moving_average is compare than logic not_kw identifier integer float dot comma lparen rparen ema_kw ema_period.

Rootsymbol command.

%% Command: buy/sell with optional condition
command -> action_clause dot
        : {command, '$1', none}.

command -> action_clause when_kw condition_clause dot
        : {command, '$1', '$3'}.

%% Action clause: buy/sell quantity shares of symbol
action_clause -> action integer shares of identifier
        : {action, element(2, '$1'), '$2', '$5'}.

action_clause -> action integer of identifier
        : {action, element(2, '$1'), '$2', '$4'}.

action_clause -> action identifier
        : {action, element(2, '$1'), 1, '$2'}.

%% Condition clause
condition_clause -> condition
        : '$1'.

condition_clause -> condition logic condition
        : {logic_op, element(2, '$2'), '$1', '$3'}.

condition_clause -> not_kw condition
        : {not_op, '$2'}.

condition -> expression compare expression
        : {comparison, element(2, '$2'), '$1', '$3'}.

condition -> expression compare than expression
        : {comparison, element(2, '$2'), '$1', '$4'}.

condition -> expression is compare expression
        : {comparison, element(2, '$3'), '$1', '$4'}.

condition -> expression is compare than expression
        : {comparison, element(2, '$3'), '$1', '$5'}.

condition -> price compare expression
        : {price_comparison, element(2, '$2'), '$3'}.

condition -> price is compare expression
        : {price_comparison, element(2, '$3'), '$4'}.

condition -> price is compare than expression
        : {price_comparison, element(2, '$3'), '$4'}.

condition -> volume compare expression
        : {volume_comparison, element(2, '$2'), '$3'}.

condition -> volume is compare expression
        : {volume_comparison, element(2, '$3'), '$4'}.

condition -> volume is compare than expression
        : {volume_comparison, element(2, '$3'), '$4'}.

condition -> volatility compare expression
        : {volatility_comparison, element(2, '$2'), '$3'}.

condition -> volatility is compare expression
        : {volatility_comparison, element(2, '$3'), '$4'}.

condition -> volatility is compare than expression
        : {volatility_comparison, element(2, '$3'), '$4'}.

%% Moving Average Conditions
condition_clause -> ma_condition
        : '$1'.

condition_clause -> ema_condition
        : '$1'.

condition_clause -> volatility_condition
        : '$1'.

ma_condition -> price moving_average integer compare expression
        : {price_ma_comparison, element(2, '$2'), element(3, '$2'), '$4'}.

ma_condition -> price moving_average integer is compare expression
        : {price_ma_comparison, element(2, '$2'), element(3, '$2'), '$5'}.

ma_condition -> volume moving_average integer compare expression
        : {volume_ma_comparison, element(2, '$2'), element(3, '$2'), '$4'}.

ma_condition -> volume moving_average integer is compare expression
        : {volume_ma_comparison, element(2, '$2'), element(3, '$2'), '$5'}.

ma_condition -> volatility moving_average integer compare expression
        : {volatility_ma_comparison, element(2, '$2'), element(3, '$2'), '$4'}.

ma_condition -> volatility moving_average integer is compare expression
        : {volatility_ma_comparison, element(2, '$2'), element(3, '$2'), '$5'}.

%% EMA Conditions
ema_condition -> price ema_kw integer compare expression
        : {ema_comparison, price, element(3, '$2'), element(4, '$3'), '$5'}.

ema_condition -> price ema_kw integer is compare expression
        : {ema_comparison, price, element(3, '$2'), element(4, '$3'), '$6'}.

ema_condition -> volume ema_kw integer compare expression
        : {ema_comparison, volume, element(3, '$2'), element(4, '$3'), '$5'}.

ema_condition -> volume ema_kw integer is compare expression
        : {ema_comparison, volume, element(3, '$2'), element(4, '$3'), '$6'}.

ema_condition -> price ema_kw integer greater than identifier
        : {ema_crossover, price, element(3, '$2'), '$5'}.

ema_condition -> price ema_kw integer less than identifier
        : {ema_crossover, price, element(3, '$2'), '$5'}.

%% Volatility Conditions
volatility_condition -> volatility compare expression
        : {volatility_comparison, element(2, '$1'), '$3'}.

volatility_condition -> volatility is compare expression
        : {volatility_comparison, element(2, '$1'), '$4'}.

%% Expressions
expression -> identifier
        : {identifier, element(2, '$1')}.

expression -> integer
        : {integer, element(2, '$1')}.

expression -> float
        : {float, element(2, '$1')}.

expression -> lparen expression rparen
        : '$2'.

Erlang code.