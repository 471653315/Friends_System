%%%-------------------------------------------------------------------
%%% @author Rxsi
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 十二月 2018 20:24
%%%-------------------------------------------------------------------
-module(friends_client).
-author("Rxsi").
-include("proto.hrl").
-compile(export_all).
-define(SERVER, ?MODULE).
start() ->
  {ok, Socket} = gen_tcp:connect("localhost", 2345, [binary, {active, false}, {packet, 0}]),
  register(
    send_msg,
    spawn(fun() -> send_msg(Socket) end)
  ),
  register(
    receive_msg,
    spawn(fun() -> receive_msg(Socket) end)
  ),
  ok.

register_account(Id, Passwd) ->
  {ok, Len, Packet} = packet:client(?REGISTER, [Id, Passwd]),
  send_msg ! {Len, Packet},
  ok.

login(Id, Passwd) ->
  {ok, Len, Packet} = packet:client(?LOGIN, [Id, Passwd]),
  send_msg ! {Len, Packet},
  ok.

apply(Id) ->
  {ok, Len, Packet} = packet:client(?APPLY, [Id]),
  send_msg ! {Len, Packet},
  ok.

accept(Id) ->
  {ok, Len, Packet} = packet:client(?ACCEPT, [Id]),
  send_msg ! {Len, Packet},
  ok.

refuse(Id) ->
  {ok, Len, Packet} = packet:client(?REFUSE, [Id]),
  send_msg ! {Len, Packet},
  ok.

defriend(Id) ->
  {ok, Len, Packet} = packet:client(?DEFRIEND, [Id]),
  send_msg ! {Len, Packet},
  ok.

delete_friend(Id) ->
  {ok, Len, Packet} = packet:client(?DELETEFRIEND, [Id]),
  send_msg ! {Len, Packet},
  ok.

delete_blacker(Id) ->
  {ok, Len, Packet} = packet:client(?DELETEBLACKER, [Id]),
  send_msg ! {Len, Packet},
  ok.

show_friends() ->
  {ok, Len, Packet} = packet:client(?SHOWFRIEND),
  send_msg ! {Len, Packet},
  ok.

show_blackers() ->
  {ok, Len, Packet} = packet:client(?SHOWBLACKER),
  send_msg ! {Len, Packet},
  ok.

show_apply() ->
  {ok, Len, Packet} = packet:client(?SHOWAPPLY),
  send_msg ! {Len, Packet},
  ok.

show_all() ->
  {ok, Len, Packet} = packet:client(?SHOWALL),
  send_msg ! {Len, Packet},
  ok.

send_msg(Socket) ->
  receive
    {Len, Packet} ->
      gen_tcp:send(Socket, <<Len:16>>),
      gen_tcp:send(Socket, Packet)
  end,
  send_msg(Socket).

receive_msg(Socket) ->
  case gen_tcp:recv(Socket, 2) of
    {ok, <<Len:16>>} ->
      case gen_tcp:recv(Socket, Len) of
        {ok, <<?REGISTER:16, Msg_binary/binary>>} ->
          Msg = binary_to_term(Msg_binary),
          io:format("register ~p~n", [Msg]),
          receive_msg(Socket);

        {ok, <<?LOGIN:16, Msg_binary/binary>>} ->
          Msg = binary_to_term(Msg_binary),
          io:format("login ~p~n", [Msg]),
          receive_msg(Socket);

        {ok,<<?SHOWFRIEND:16,Msg_binary/binary>>} ->
          Msg=binary_to_term(Msg_binary),
          io:format("friends: ~p~n",[Msg]),
          receive_msg(Socket);

        {ok,<<?SHOWBLACKER:16,Msg_binary/binary>>} ->
          Msg=binary_to_term(Msg_binary),
          io:format("blackers: ~p~n",[Msg]),
          receive_msg(Socket);

        {ok,<<?SHOWAPPLY:16,Msg_binary/binary>>} ->
          Msg=binary_to_term(Msg_binary),
          io:format("applicants: ~p~n",[Msg]),
          receive_msg(Socket);

        {ok,<<?SHOWALL:16,Msg_binary/binary>>} ->
          Msg=binary_to_term(Msg_binary),
          io:format("~p~n",[Msg]),
          receive_msg(Socket);

        {ok,<<?APPLY:16,Msg_binary/binary>>} ->
          Msg=binary_to_term(Msg_binary),
          io:format("apply ~p~n",[Msg]),
          receive_msg(Socket);

        {ok,<<?ACCEPT:16,Msg_binary/binary>>} ->
          Msg=binary_to_term(Msg_binary),
          io:format("accept ~p~n",[Msg]),
          receive_msg(Socket);

        {ok,<<?REFUSE:16,Msg_binary/binary>>} ->
          Msg=binary_to_term(Msg_binary),
          io:format("refuse ~p~n",[Msg]),
          receive_msg(Socket);

        {ok,<<?DEFRIEND:16,Msg_binary/binary>>} ->
          Msg=binary_to_term(Msg_binary),
          io:format("defriend ~p~n",[Msg]),
          receive_msg(Socket);

        {ok,<<?DELETEFRIEND:16,Msg_binary/binary>>} ->
          Msg=binary_to_term(Msg_binary),
          io:format("delete_friend ~p~n",[Msg]),
          receive_msg(Socket);

        {ok,<<?DELETEBLACKER:16,Msg_binary/binary>>} ->
          Msg=binary_to_term(Msg_binary),
          io:format("delete_blacker ~p~n",[Msg]),
          receive_msg(Socket)

      end
  end.