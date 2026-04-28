-module(instruments).
 -module(instruments).
 -export([
     %% basic references
     stock/1,
     bond/2,
     rate/1,

     %% DSL helpers
     terminal/1,
     path/1,
     constant/1,

     %% transformations
     binary/2,
     diff/2,
     max_of/1,
     min_of/1,

     %% composition helpers
     add/2,
     choice/2
 ]).

%% =========================
%% BASIC INSTRUMENT REFERENCES
%% =========================

%% NOTE: these are NOT objects anymore
%% they are identifiers used in DSL

stock(Symbol) ->
    Symbol.

bond(Name, _Type) ->
    Name.

rate(Name) ->
    {rate, Name}.

%% =========================
%% OBSERVATION HELPERS
%% =========================

terminal(Asset) ->
    {observe, {terminal, Asset}}.

path(Asset) ->
    {observe, {path, Asset}}.

%% =========================
%% CONSTANT
%% =========================

constant(X) ->
    {constant, X}.

%% =========================
%% TRANSFORMATIONS
%% =========================

binary(K, Obs) ->
    {transform, {binary, K}, Obs}.

diff(A, B) ->
    {transform, diff,
        {observe, {multi, [A, B]}}}.

max_of(Assets) ->
    {transform, max_of,
        {observe, {multi, Assets}}}.

min_of(Assets) ->
    {transform, min_of,
        {observe, {multi, Assets}}}.

%% =========================
%% COMPOSITION
%% =========================

add(C1, C2) ->
    {combine, add, C1, C2}.

choice(C1, C2) ->
    {choice, C1, C2}.