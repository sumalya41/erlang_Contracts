Definitions.

D = [0-9]
L = [a-zA-Z]
WS = [\s\t\n\r]

Rules.

{WS}+                 : skip_token.
buy|sell              : {token, {action, TokenChars}}.
shares?               : {token, {shares, TokenChars}}.
"of"                  : {token, {'of', TokenChars}}.
when                  : {token, {when_kw, TokenChars}}.
price                 : {token, {price, TokenChars}}.
volume                : {token, {volume, TokenChars}}.
volatility            : {token, {volatility, TokenChars}}.
moving_average        : {token, {ma, TokenChars}}.
ema                   : {token, {ema_kw, TokenChars}}.
is                    : {token, {is, TokenChars}}.
less|greater          : {token, {compare, TokenChars}}.
than                  : {token, {than, TokenChars}}.
at|above|below        : {token, {compare, TokenChars}}.
and|or                : {token, {logic, TokenChars}}.
not                   : {token, {not_kw, TokenChars}}.
{L}+                  : {token, {identifier, TokenChars}}.
{D}+                  : {token, {integer, list_to_integer(TokenChars)}}.
{D}+\.{D}+            : {token, {float, list_to_float(TokenChars)}}.
\.                    : {token, {dot, TokenChars}}.
,                     : {token, {comma, TokenChars}}.
\(                    : {token, {lparen, TokenChars}}.
\)                    : {token, {rparen, TokenChars}}.

Erlang code.