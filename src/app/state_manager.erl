%%%-------------------------------------------------------------------
%%% @author Rxsi
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. 十二月 2018 15:02
%%%-------------------------------------------------------------------
-module(state_manager).
-author("Rxsi").
-compile(export_all).
-include("user_info.hrl").
-record(state,{datalist=[]}).

register_account(Id,Passwd,#state{datalist = DataList}= State) ->
  NewDataList = lists:keystore(Id, #user.id, DataList, #user{id = Id, passwd = Passwd}),
  NewState = State#state{datalist = NewDataList},
  {ok, NewState}.

get_from_name(Id,#state{datalist = DataList}=State) ->
  lists:keyfind(Id,#user.id,DataList).

set_socket(Id,Socket,#state{datalist = DataList}=State) ->
  NewDataList = case lists:keyfind(Id,#user.id,DataList) of
                  #user{} = User ->
                    lists:keystore(Id,#user.id,DataList,User#user{socket = Socket});
                  _ ->
                    DataList
                end,
  NewState = State#state{datalist = NewDataList},
  {ok,NewState}.

check_login(Socket,#state{datalist = DataList} =State) ->
  lists:keyfind(Socket,#user.socket,DataList).

get_from_socket(Socket,#state{datalist = DataList}=State) ->
  lists:keyfind(Socket,#user.socket,DataList).
