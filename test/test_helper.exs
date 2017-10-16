ExUnit.start()

defmodule AppMaker do
  defmacro __using__(options) do
    quote do
      use Plug.Router
      alias Plug.Conn.Status

      plug PlugOpenTracing, unquote(options)
      plug :match
      plug :dispatch
    end
  end
end

defmodule TestApp do
  alias :otter, as: Otter
  use AppMaker, trace_header: "uber-trace-id"

  get "/test-path" do
    send_resp(conn, Status.code(:ok), ids_to_string(conn))
  end

  defp ids_to_string(conn) do
    {trace_id, _} = Otter.ids(conn.assigns[:trace_span])
    "#{Integer.to_string(trace_id)}"
  end
end
