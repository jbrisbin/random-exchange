%% The contents of this file are subject to the Mozilla Public License
%% Version 1.1 (the "License"); you may not use this file except in
%% compliance with the License. You may obtain a copy of the License
%% at http://www.mozilla.org/MPL/
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and
%% limitations under the License.
%%
%% The Original Code is RabbitMQ.
%%
%% The Initial Developer of the Original Code is VMware, Inc.
%% Copyright (c) 2007-2011 VMware, Inc.  All rights reserved.
%%

-module(rabbit_exchange_type_random).
-behaviour(rabbit_exchange_type).
-include_lib("rabbit_common/include/rabbit.hrl").

-rabbit_boot_step({?MODULE, [
  {description,   "exchange type random"},
  {mfa,           {rabbit_registry, register, [exchange, <<"x-random">>, ?MODULE]}},
  {requires,      rabbit_registry},
  {enables,       kernel_ready}
]}).

-export([
  add_binding/3, 
  assert_args_equivalence/2,
  create/2, 
  delete/3, 
  policy_changed/2,
  description/0, 
  recover/2, 
  remove_bindings/3,
  validate_binding/2,
  route/2,
  serialise_events/0,
  validate/1
]).

description() ->
    [{name, <<"x-random">>}, {description, <<"AMQP random exchange. Like a direct exchange, but randomly chooses who to route to.">>}].

route(_X=#exchange{name = Name},
      _D=#delivery{message = #basic_message{routing_keys = Routes}}) ->
    Matches = rabbit_router:match_routing_key(Name, Routes),
    %io:format("exchange: ~p~n", [X]),
    %io:format("delivery: ~p~n", [D]),
    %io:format("matches: ~p~n", [Matches]),
    case length(Matches) of
      Len when Len < 2 -> Matches;
      Len ->
        Rand = crypto:rand_uniform(1, Len + 1),
        [lists:nth(Rand, Matches)]
    end.

serialise_events() -> false.
validate(_X) -> ok.
create(_Tx, _X) -> ok.
recover(_X, _Bs) -> ok.
delete(_Tx, _X, _Bs) -> ok.
policy_changed(_X1, _X2) -> ok.
add_binding(_Tx, _X, _B) -> ok.
remove_bindings(_Tx, _X, _Bs) -> ok.
validate_binding(_X, _B) -> ok.
assert_args_equivalence(X, Args) ->
    rabbit_exchange:assert_args_equivalence(X, Args).
