# pushover_error_logger

A logger handler that sends error logs to Pushover. Good for micro apps that
don't need full blown exception monitoring systems like Sentry, Rollbar, etc.

Pushover permits 10,000 messages per application per month, so be careful not to
exceed that limit. Pull requests to add a configurable rate limit or debouncing
are welcome.

Error messages over 1024 characters are truncated to fit the Pushover API limit.

TLS is verified using operating system CA certificates loaded with
[`public_key:cacerts_get/0`](http://erlang.org/doc/man/public_key.html#cacerts_get-0)
so OTP-25.0 or greater is required and CA certificates must be installed on the
host or container running your application.


## Usage

Add `pushover_error_logger` as a dependency to your project and call the
`install/3` function once when you application starts.

### Erlang

```erlang
start(_, _) ->
    pushover_error_logger:install(
        "my-cool-web-app",
        "pushover-user-key",
        "pushover-application-token"
    ),
    % ...your code here
```

### Elixir

```elixir
def start(_, _) do
  :pushover_error_logger.install(
      "my-cool-web-app",
      "pushover-user-key",
      "pushover-application-token"
  )
  # ...your code here
end
```

### Gleam

```gleam
pub fn main() {
  install_error_logger(
      "my-cool-web-app",
      "pushover-user-key",
      "pushover-application-token"
  )
  // ...your code here
}

external fn install_error_logger(String, String, String) -> Nil =
    "pushover_error_logger" "install"
  ```
