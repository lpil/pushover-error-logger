-module(pushover_error_logger).

-export([install/3]).

% Logger callbacks
-export([log/2]).

-record(config, {
    instance_name :: binary(),
    user :: binary(),
    token :: binary()
}).

-spec install(binary(), binary(), binary()) -> nil.
install(InstanceName, User, Token) ->
    HandlerConfig = #config{
        instance_name = InstanceName,
        user = User,
        token = Token
    },
    Config = #{
        config => HandlerConfig
    },
    ok = logger:add_handler(?MODULE, ?MODULE, Config),
    nil.

log(#{msg := Error, level := error}, #{config := Config}) ->
    try
        Data = case Error of
            {string, String} when is_binary(String) -> String;
            {string, String} -> anything_to_binary(String);
            Other -> anything_to_binary(Other)
        end,
        send_to_pushover(Data, Config)
    catch
        _:EmailError -> logger:warning(anything_to_binary({
            failed_to_send_error_to_pushover, EmailError
        }))
    end;
log(_, _) ->
    ok.

send_to_pushover(
    Error,
    #config{instance_name = InstanceName, user = User, token = Token}
) when is_binary(Error) ->
    CaCerts = public_key:cacerts_get(),
    Message = unicode:characters_to_binary(
        io_lib:format("~s error: ~s", [InstanceName, Error])
    ),
    Body = uri_string:compose_query([
        {"token", Token},
        {"user", User},
        % Pushover has a max body size of 1024 characters
        {"message", string:slice(Message, 0, 1024)}
    ]),
    Endpoint = "https://api.pushover.net/1/messages.json",
    Request = {Endpoint, [], "application/x-www-form-urlencoded", Body},
    HttpOptions = [
        {ssl, [
            {cacerts, CaCerts},
            {verify, verify_peer},
            {customize_hostname_check, [
                {match_fun, public_key:pkix_verify_hostname_match_fun(https)}
            ]}
        ]}
    ],
    case httpc:request(post, Request, HttpOptions, []) of
        {ok, {{_, 200, _}, _, _}} -> ok;
        {ok, {200, _}} -> ok;
        Other -> erlang:error(Other)
    end.



anything_to_binary(Term) ->
    list_to_binary(io_lib:format("~p", [Term])).

