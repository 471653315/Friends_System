%%%-------------------------------------------------------------------
%%% @author Rxsi
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 十二月 2018 16:22
%%%-------------------------------------------------------------------
-module(friends_server).
-author("Rxsi").
-compile(export_all).
-define(SERVER, ?MODULE).
-include("proto.hrl").

start() ->
  start_parallel_server(),
  user_manager:start_link(),
  friends_system:start_link().

start_parallel_server() ->
  {ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 0}, {reuseaddr, true}, {active, false}]),
  spawn(fun() -> per_connect(Listen) end).

per_connect(Listen) ->
  {ok, Socket} = gen_tcp:accept(Listen),
  spawn(fun() -> per_connect(Listen) end),
  loop(Socket).

loop(Socket) ->
  case gen_tcp:recv(Socket, 2) of
    {ok, <<Len:16>>} ->
      case gen_tcp:recv(Socket, Len) of
        {ok, <<?REGISTER:16, Len1:16, Data/binary>>} ->
          <<Id_binary:Len1/binary, Len2:16, Passwd_binary/binary>> = Data,
          Id = binary_to_term(Id_binary),
          Passwd = binary_to_term(Passwd_binary),
          gen_server:cast(user_manager, {register, Id, Passwd, Socket}),
          loop(Socket);

        {ok, <<?LOGIN:16, Len1:16, Data/binary>>} ->
          <<Id_binary:Len1/binary, Len2:16, Passwd_binary/binary>> = Data,
          Id = binary_to_term(Id_binary),
          Passwd = binary_to_term(Passwd_binary),
          gen_server:cast(user_manager, {login, Id, Passwd, Socket}),
          loop(Socket);

        {ok, <<?SHOWFRIEND:16>>} ->
          gen_server:cast(friends_system, {show_friends, Socket}),
          loop(Socket);

        {ok, <<?SHOWBLACKER:16>>} ->
          gen_server:cast(friends_system, {show_blackers, Socket}),
          loop(Socket);

        {ok, <<?SHOWAPPLY:16>>} ->
          gen_server:cast(friends_system, {show_applicants, Socket}),
          loop(Socket);

        {ok, <<?SHOWALL:16>>} ->
          gen_server:cast(friends_system, {show_all, Socket}),
          loop(Socket);

        {ok,<<?APPLY:16,Data/binary>>} ->
          Id=binary_to_term(Data),
          gen_server:cast(friends_system,{apply,Id,Socket}),
          loop(Socket);

        {ok,<<?ACCEPT:16,Data/binary>>} ->
          Id=binary_to_term(Data),
          gen_server:cast(friends_system,{accept,Id,Socket}),
          loop(Socket);

        {ok,<<?REFUSE:16,Data/binary>>} ->
          Id=binary_to_term(Data),
          gen_server:cast(friends_system,{refuse,Id,Socket}),
          loop(Socket);

        {ok,<<?DEFRIEND:16,Data/binary>>} ->
          Id=binary_to_term(Data),
          gen_server:cast(friends_system,{defriend,Id,Socket}),
          loop(Socket);

        {ok,<<?DELETEFRIEND:16,Data/binary>>} ->
          Id=binary_to_term(Data),
          gen_server:cast(friends_system,{delete_friend,Id,Socket}),
          loop(Socket);

        {ok,<<?DELETEBLACKER:16,Data/binary>>} ->
          Id=binary_to_term(Data),
          gen_server:cast(friends_system,{delete_blacker,Id,Socket}),
          loop(Socket)

      end
  end.