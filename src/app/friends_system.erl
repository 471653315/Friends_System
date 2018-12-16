%%%-------------------------------------------------------------------
%%% @author Rxsi
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. 十二月 2018 16:25
%%%-------------------------------------------------------------------
-module(friends_system).
-author("Rxsi").
-behaviour(gen_server).

-compile(export_all).
-define(SERVER, ?MODULE).
-include("friend_list.hrl").
-include("friend_data.hrl").
-include("proto.hrl").

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
  init_ets(),
  {ok, 0}.

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast({show_friends, Socket}, State) ->
  Reply = gen_server:call(user_manager, {check_login, Socket}),
  case Reply of
    "success" ->
      Owner = gen_server:call(user_manager, {get_id, Socket}),
      List = ets:lookup_element(?ETSATOM, Owner, #friend_list.friendlist),
      Msg = [Good#friend_data.userid || Good <- List, Good#friend_data.type =:= ?GOOD];
    "fail" ->
      Msg = "fail"
  end,
  {ok, Len, Packet} = packet:friend(?SHOWFRIEND, [Msg]),
  gen_tcp:send(Socket, <<Len:16>>),
  gen_tcp:send(Socket, Packet),
  {noreply, State};

handle_cast({show_blackers, Socket}, State) ->
  Reply = gen_server:call(user_manager, {check_login, Socket}),
  case Reply of
    "success" ->
      Owner = gen_server:call(user_manager, {get_id, Socket}),
      List = ets:lookup_element(?ETSATOM, Owner, #friend_list.friendlist),
      Msg = [Blacker#friend_data.userid || Blacker <- List, Blacker#friend_data.type =:= ?BLACK];
    "fail" ->
      Msg = "fail"
  end,
  {ok, Len, Packet} = packet:friend(?SHOWBLACKER, [Msg]),
  gen_tcp:send(Socket, <<Len:16>>),
  gen_tcp:send(Socket, Packet),
  {noreply, State};

handle_cast({show_applicants, Socket}, State) ->
  Reply = gen_server:call(user_manager, {check_login, Socket}),
  case Reply of
    "success" ->
      Owner = gen_server:call(user_manager, {get_id, Socket}),
      List = ets:lookup_element(?ETSATOM, Owner, #friend_list.friendlist),
      Msg = [Apply#friend_data.userid || Apply <- List, Apply#friend_data.type =:= ?APPLY];
    "fail" ->
      Msg = "fail"
  end,
  {ok, Len, Packet} = packet:friend(?SHOWAPPLY, [Msg]),
  gen_tcp:send(Socket, <<Len:16>>),
  gen_tcp:send(Socket, Packet),
  {noreply, State};

handle_cast({show_all, Socket}, State) ->
  Reply = gen_server:call(user_manager, {check_login, Socket}),
  case Reply of
    "success" ->
      Owner = gen_server:call(user_manager, {get_id, Socket}),
      List = ets:lookup_element(?ETSATOM, Owner, #friend_list.friendlist),
      Msg4="friends: ",
      {ok, Len4, Packet4} = packet:friend(?SHOWALL, [Msg4]),
      gen_tcp:send(Socket, <<Len4:16>>),
      gen_tcp:send(Socket, Packet4),
      Msg_friend = [Good#friend_data.userid || Good <- List, Good#friend_data.type =:= ?GOOD],
      {ok, Len, Packet} = packet:friend(?SHOWALL, [Msg_friend]),
      gen_tcp:send(Socket, <<Len:16>>),
      gen_tcp:send(Socket, Packet),

      Msg5="apply: ",
      {ok, Len5, Packet5} = packet:friend(?SHOWALL, [Msg5]),
      gen_tcp:send(Socket, <<Len5:16>>),
      gen_tcp:send(Socket, Packet5),
      Msg_apply = [Apply#friend_data.userid || Apply <- List, Apply#friend_data.type =:= ?APPLY],
      {ok, Len2, Packet2} = packet:friend(?SHOWALL, [Msg_apply]),
      gen_tcp:send(Socket, <<Len2:16>>),
      gen_tcp:send(Socket, Packet2),

      Msg6="blackers: ",
      {ok, Len6, Packet6} = packet:friend(?SHOWALL, [Msg6]),
      gen_tcp:send(Socket, <<Len6:16>>),
      gen_tcp:send(Socket, Packet6),
      Msg_blacker = [Blacker#friend_data.userid || Blacker <- List, Blacker#friend_data.type =:= ?BLACK],
      {ok, Len3, Packet3} = packet:friend(?SHOWALL, [Msg_blacker]),
      gen_tcp:send(Socket, <<Len3:16>>),
      gen_tcp:send(Socket, Packet3);
    "fail" ->
      Msg = "fail",
      {ok, Len4, Packet4} = packet:friend(?SHOWAPPLY, [Msg]),
      gen_tcp:send(Socket, <<Len4:16>>),
      gen_tcp:send(Socket, Packet4)
  end,
  {noreply, State};

handle_cast({apply, Id, Socket}, State) ->
  Reply = gen_server:call(user_manager, {check_login, Socket}),
  case Reply of
    "success" ->
      Owner = gen_server:call(user_manager, {get_id, Socket}),
      List = ets:lookup_element(?ETSATOM, Id, #friend_list.friendlist),
      Type = lists:keyfind(Owner, #friend_data.userid, List),
      case Type of
        false ->
          Msg = "success",
          NewList = lists:keystore(Owner, #friend_data.userid, List, #friend_data{userid = Owner, type = ?APPLY}),
          ets:update_element(?ETSATOM, Id, {#friend_list.friendlist, NewList});
        _ ->
          Msg = "fail"
      end;
    "fail" ->
      Msg = "fail"
  end,
  {ok, Len, Packet} = packet:friend(?APPLY, [Msg]),
  gen_tcp:send(Socket, <<Len:16>>),
  gen_tcp:send(Socket, Packet),
  {noreply, State};

handle_cast({accept, Id, Socket}, State) ->
  Reply = gen_server:call(user_manager, {check_login, Socket}),
  case Reply of
    "success" ->
      Owner = gen_server:call(user_manager, {get_id, Socket}),
      List = ets:lookup_element(?ETSATOM, Owner, #friend_list.friendlist),
      Type = lists:keyfind(Id, #friend_data.userid, List),
      case Type#friend_data.type of
        ?APPLY ->
          NewList = lists:keystore(Id, #friend_data.userid, List, #friend_data{userid = Id, type = ?GOOD}),
          ets:update_element(?ETSATOM, Owner, {#friend_list.friendlist, NewList}),
          Msg = "success";
        _ ->
          Msg = "fail"
      end;
    "fail" ->
      Msg = "fail"
  end,
  {ok, Len, Packet} = packet:friend(?ACCEPT, [Msg]),
  gen_tcp:send(Socket, <<Len:16>>),
  gen_tcp:send(Socket, Packet),
  {noreply, State};

handle_cast({refuse, Id, Socket}, State) ->
  Reply = gen_server:call(user_manager, {check_login, Socket}),
  case Reply of
    "success" ->
      Owner = gen_server:call(user_manager, {get_id, Socket}),
      List = ets:lookup_element(?ETSATOM, Owner, #friend_list.friendlist),
      Type = lists:keyfind(Id, #friend_data.userid, List),
      case Type#friend_data.type of
        ?APPLY ->
          NewList = lists:keystore(Id, #friend_data.userid, List, #friend_data{userid = Id, type = ?REFUSE}),
          ets:update_element(?ETSATOM, Owner, {#friend_list.friendlist, NewList}),
          Msg = "success";
        _ ->
          Msg = "fail"
      end;

    "fail" ->
      Msg = "fail"
  end,
  {ok, Len, Packet} = packet:friend(?REFUSE, [Msg]),
  gen_tcp:send(Socket, <<Len:16>>),
  gen_tcp:send(Socket, Packet),
  {noreply, State};

handle_cast({defriend, Id, Socket}, State) ->
  Reply = gen_server:call(user_manager, {check_login, Socket}),
  case Reply of
    "success" ->
      Owner = gen_server:call(user_manager, {get_id, Socket}),
      List = ets:lookup_element(?ETSATOM, Owner, #friend_list.friendlist),
      NewList = lists:keystore(Id, #friend_data.userid, List, #friend_data{userid = Id, type = ?BLACK}),
      ets:update_element(?ETSATOM, Owner, {#friend_list.friendlist, NewList}),
      Msg = "success";
    "fail" ->
      Msg = "fail"
  end,
  {ok, Len, Packet} = packet:friend(?DEFRIEND, [Msg]),
  gen_tcp:send(Socket, <<Len:16>>),
  gen_tcp:send(Socket, Packet),
  {noreply, State};

handle_cast({delete_friend, Id, Socket}, State) ->
  Reply = gen_server:call(user_manager, {check_login, Socket}),
  case Reply of
    "success" ->
      Owner = gen_server:call(user_manager, {get_id, Socket}),
      List = ets:lookup_element(?ETSATOM, Owner, #friend_list.friendlist),
      Type = lists:keyfind(Id, #friend_data.userid, List),
      case Type#friend_data.type of
        ?GOOD ->
          NewList = lists:keydelete(Id, #friend_data.userid, List),
          ets:update_element(?ETSATOM, Owner, {#friend_list.friendlist, NewList}),
          Msg = "success";
        _ ->
          Msg = "fail"
      end;

    "fail" ->
      Msg = "fail"
  end,
  {ok, Len, Packet} = packet:friend(?DELETEFRIEND, [Msg]),
  gen_tcp:send(Socket, <<Len:16>>),
  gen_tcp:send(Socket, Packet),
  {noreply, State};

handle_cast({delete_blacker, Id, Socket}, State) ->
  Reply = gen_server:call(user_manager, {check_login, Socket}),
  case Reply of
    "success" ->
      Owner = gen_server:call(user_manager, {get_id, Socket}),
      List = ets:lookup_element(?ETSATOM, Owner, #friend_list.friendlist),
      Type = lists:keyfind(Id, #friend_data.userid, List),
      case Type#friend_data.type of
        ?BLACK ->
          NewList = lists:keydelete(Id, #friend_data.userid, List),
          ets:update_element(?ETSATOM, Owner, {#friend_list.friendlist, NewList}),
          Msg = "success";
        _ ->
          Msg = "fail"
      end;

    "fail" ->
      Msg = "fail"
  end,
  {ok, Len, Packet} = packet:friend(?DELETEBLACKER, [Msg]),
  gen_tcp:send(Socket, <<Len:16>>),
  gen_tcp:send(Socket, Packet),
  {noreply, State};

handle_cast({add_id, Id}, State) ->
  ets:insert(?ETSATOM, #friend_list{userid = Id, friendlist = []}),
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

init_ets() ->
  ets:new(?ETSATOM, [set, public, named_table, {keypos, #friend_list.userid}]).