%%%-------------------------------------------------------------------
%%% @author Rxsi
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. 十二月 2018 10:00
%%%-------------------------------------------------------------------
-module(packet).
-author("Rxsi").
-compile(export_all).
-include("proto.hrl").

client(?REGISTER,[Id,Passwd]) ->
  Data1=term_to_binary(Id),
  Data2=term_to_binary(Passwd),
  Len1 = byte_size(Data1),
  Len2=byte_size(Data2),
  Packet= <<?REGISTER:16,Len1:16,Data1/binary,Len2:16,Data2/binary>>,
  Len=byte_size(Packet),
  {ok,Len,Packet};

client(?LOGIN,[Id,Passwd]) ->
  Data1=term_to_binary(Id),
  Data2=term_to_binary(Passwd),
  Len1 = byte_size(Data1),
  Len2=byte_size(Data2),
  Packet= <<?LOGIN:16,Len1:16,Data1/binary,Len2:16,Data2/binary>>,
  Len=byte_size(Packet),
  {ok,Len,Packet};

client(?APPLY,[Id]) ->
  Data=term_to_binary(Id),
  Packet= <<?APPLY:16,Data/binary>>,
  Len=byte_size(Packet),
  {ok,Len,Packet};

client(?ACCEPT,[Id]) ->
  Data=term_to_binary(Id),
  Packet= <<?ACCEPT:16,Data/binary>>,
  Len=byte_size(Packet),
  {ok,Len,Packet};

client(?REFUSE,[Id]) ->
  Data=term_to_binary(Id),
  Packet= <<?REFUSE:16,Data/binary>>,
  Len=byte_size(Packet),
  {ok,Len,Packet};

client(?DEFRIEND,[Id]) ->
  Data=term_to_binary(Id),
  Packet= <<?DEFRIEND:16,Data/binary>>,
  Len=byte_size(Packet),
  {ok,Len,Packet};

client(?DELETEFRIEND,[Id]) ->
  Data=term_to_binary(Id),
  Packet= <<?DELETEFRIEND:16,Data/binary>>,
  Len=byte_size(Packet),
  {ok,Len,Packet};

client(?DELETEBLACKER,[Id]) ->
  Data=term_to_binary(Id),
  Packet= <<?DELETEBLACKER:16,Data/binary>>,
  Len=byte_size(Packet),
  {ok,Len,Packet}.

client(?SHOWFRIEND) ->
  Packet= <<?SHOWFRIEND:16>>,
  Len=byte_size(Packet),
  {ok,Len,Packet};

client(?SHOWBLACKER) ->
  Packet= <<?SHOWBLACKER:16>>,
  Len=byte_size(Packet),
  {ok,Len,Packet};

client(?SHOWAPPLY) ->
  Packet= <<?SHOWAPPLY:16>>,
  Len=byte_size(Packet),
  {ok,Len,Packet};

client(?SHOWALL) ->
  Packet= <<?SHOWALL:16>>,
  Len=byte_size(Packet),
  {ok,Len,Packet}.

server(?REGISTER,[Msg]) ->
  Data=term_to_binary(Msg),
  Packet= <<?REGISTER:16,Data/binary>>,
  Len=byte_size(Packet),
  {ok,Len,Packet};

server(?LOGIN,[Msg]) ->
  Data=term_to_binary(Msg),
  Packet= <<?LOGIN:16,Data/binary>>,
  Len=byte_size(Packet),
  {ok,Len,Packet}.

friend(?SHOWFRIEND,[Msg]) ->
  Data=term_to_binary(Msg),
  Packet = <<?SHOWFRIEND:16,Data/binary>>,
  Len=byte_size(Packet),
  {ok,Len,Packet};

friend(?SHOWBLACKER,[Msg]) ->
  Data=term_to_binary(Msg),
  Packet = <<?SHOWBLACKER:16,Data/binary>>,
  Len=byte_size(Packet),
  {ok,Len,Packet};

friend(?SHOWAPPLY,[Msg]) ->
  Data=term_to_binary(Msg),
  Packet = <<?SHOWAPPLY:16,Data/binary>>,
  Len=byte_size(Packet),
  {ok,Len,Packet};

friend(?SHOWALL,[Msg]) ->
  Data=term_to_binary(Msg),
  Packet = <<?SHOWALL:16,Data/binary>>,
  Len=byte_size(Packet),
  {ok,Len,Packet};

friend(?APPLY,[Msg]) ->
  Data=term_to_binary(Msg),
  Packet = <<?APPLY:16,Data/binary>>,
  Len=byte_size(Packet),
  {ok,Len,Packet};

friend(?REFUSE,[Msg]) ->
  Data=term_to_binary(Msg),
  Packet = <<?REFUSE:16,Data/binary>>,
  Len=byte_size(Packet),
  {ok,Len,Packet};

friend(?DEFRIEND,[Msg]) ->
  Data=term_to_binary(Msg),
  Packet = <<?DEFRIEND:16,Data/binary>>,
  Len=byte_size(Packet),
  {ok,Len,Packet};

friend(?DELETEFRIEND,[Msg]) ->
  Data=term_to_binary(Msg),
  Packet = <<?DELETEFRIEND:16,Data/binary>>,
  Len=byte_size(Packet),
  {ok,Len,Packet};

friend(?DELETEBLACKER,[Msg]) ->
  Data=term_to_binary(Msg),
  Packet = <<?DELETEBLACKER:16,Data/binary>>,
  Len=byte_size(Packet),
  {ok,Len,Packet};

friend(?ACCEPT,[Msg]) ->
  Data=term_to_binary(Msg),
  Packet = <<?ACCEPT:16,Data/binary>>,
  Len=byte_size(Packet),
  {ok,Len,Packet}.

