-module(kvdb_schema).

-export([
	 validate/3, validate_attr/3,
	 on_update/4, encode/3, decode/3, encode_attr/3
	]).
-export([write/2, read/1, read/2]).

-export([behaviour_info/1]).

-include("kvdb.hrl").

behaviour_info(callbacks) ->
    [{validate, 3},
     {validate_attr, 3},
     {on_update, 4},
     {encode, 3},
     {decode, 3},
     {encode_attr, 3},
     {decode_attr, 3}];
behaviour_info(_) ->
    undefined.


validate(_Db, _Type, Obj) ->
    Obj.

validate_attr(_Db, _Type, Attr) ->
    Attr.

on_update(_Op, _Db, _Table, _Obj) ->
    ok.

encode(_Db, _Type, Obj) ->
    Obj.

encode_attr(_Db, _Type, Attr) ->
    Attr.

decode(_Db, _Type, Obj) ->
    Obj.

write(Db, Schema) ->
    [kvdb:put(Db, ?SCHEMA_TABLE, X) || X <- Schema],
    ok.

read(Db) ->
    match_(kvdb:select(Db, ?SCHEMA_TABLE, [{'_',[],['$_']}], 100), []).

read(Db, Item) ->
    case kvdb:get(Db, Item) of
	{ok, {_,_,V}} -> {ok, V};
	{ok, {_, V}}  -> {ok, V};
	Error ->
	    Error
    end.

match_({Objs, Cont}, Acc) ->
    match_(Cont(), acc_(Objs, Acc));
match_(done, Acc) ->
    lists:reverse(Acc).

acc_([{K,_,V}|T], Acc) ->
    acc_(T, [{K,V}|Acc]);
acc_([{_,_}|_] = L, Acc) ->
    lists:reverse(L) ++ Acc;
acc_([], Acc) ->
    Acc.


