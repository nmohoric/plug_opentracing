# PlugOpenTracing

[![Build Status](https://travis-ci.org/nmohoric/plug_opentracing.svg?branch=master)](https://travis-ci.org/nmohoric/plug_opentracing)

An Elixir Plug for adding OpenTracing instrumentation.

## Usage

Update your `mix.exs` file and run `mix deps.get`.
```elixir
defp deps do
  [{:plug_opentracing, "~> 0.1"}]
end
```

Add the plug to a pipeline. In this case we will look for the
`uber-trace-id` header to exist. If so, it is split on `:` and
the first and second values are used as the trace_id and parent_id
when creating the span.

```elixir
defmodule MyPhoenixApp.MyController do
  use MyPhoenixApp.Web, :controller
  alias Plug.Conn.Status

  plug PlugOpenTracing, trace_id: 'uber-trace-id'
  plug :action

  def index(conn, _params) do
    conn
    |> put_status(Status.code :ok)
  end
end

```
The created span can be accessed using `conn.assigns[:trace_span]`. This is useful
when you want to use this span as the parent of another span in your request, or
if you want to add tags/logs to the span before it is finished.

The request span will be finished at the end of your request using a callback,
which will send it to the Jaeger or Zipkin endpoint you've set up in your config.
