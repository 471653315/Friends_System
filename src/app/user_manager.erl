%%%-------------------------------------------------------------------
%%% @author Rxsi
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. 十二月 2018 14:48
%%%-------------------------------------------------------------------
-module(user_manager).
-author("Rxsi").

-behaviour(gen_server).
-include("user_info.hrl").
-include("proto.hrl").
-compile(export_all).
-define(SERVER, ?MODULE).
-record(state, {dataList = []}).

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
  {ok, #state{}}.

handle_call({check_login, Socket}, _From, State) ->
  Reply = case state_manager:check_login(Socket, State) of
            false ->
              "fail";
            _ ->
              "success"
          end,
  {reply, Reply, State};

handle_call({get_id, Socket}, _From, State) ->
  Reply = state_manager:get_from_socket(Socket,State),
  Id=Reply#user.id,
  {reply, Id, State}.

handle_cast({register, Id, Passwd, Socket}, State) ->
  case state_manager:get_from_name(Id, State) of
    false ->
      {ok, NewState} = state_manager:register_account(Id, Passwd, State),
      Msg = "success";
    _ ->
      NewState = State,
      Msg = "fail"
  end,
  {ok, Len, Packet} = packet:server(?REGISTER, [Msg]),
  gen_tcp:send(Socket, <<Len:16>>),
  gen_tcp:send(Socket, Packet),
  {noreply, NewState};

handle_cast({login, Id, Passwd, Socket}, State) ->
  case state_manager:get_from_name(Id, State) of
    false ->
      NewState = State,
      Msg = "fail";
    {user, Id2, Passwd2, Socket2} ->
      if
        Passwd2 =:= Passwd ->
          Msg = "success",
          {ok, NewState} = state_manager:set_socket(Id, Socket, State),
          gen_server:cast(friends_system,{add_id,Id});
        true ->
          NewState = State,
          Msg = "fail"
      end
  end,
  {ok, Len, Packet} = packet:server(?LOGIN, [Msg]),
  gen_tcp:send(Socket, <<Len:16>>),
  gen_tcp:send(Socket, Packet),
  {noreply, NewState}.


handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
