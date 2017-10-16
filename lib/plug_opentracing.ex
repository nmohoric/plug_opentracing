defmodule PlugOpenTracing do
  @moduledoc """
  A plug for adding OpenTracing instrumentation to requests.

  If a request already has a trace-id, the parts will be split
  out and added as trace-id and parent-id in the new span. Otherwise,
  a new span will be created.

  The default header is "uber-trace-id" but this can be set at compile time.

  At any point in the request you can access the span using conn.assigns[:trace].
  This can then be used to either add tags onto it or use the span as a parent span
  for other requests.

  To use it, just plug it into your module:

      plug PlugOpenTracing

  ## Options

    * `:trace_id` - An incoming trace-id. This should be hex and in the
      form `trace-id:span-id` plus any optional bits that will be removed.

        plug PlugOpenTracing, trace_id: "my-trace-header"
  """

  alias Plug.Conn
  alias :otter, as: Otter
  @behaviour Plug

  def init(opts) do
    Keyword.get(opts, :trace_header, "uber-trace-id")
  end

  def call(conn, trace_id_header) do
    conn
    |> get_trace_id(trace_id_header)
    |> start_span()
    |> tag_span()
    |> register_span()
  end

  defp get_trace_id(conn, header) do
    case Conn.get_req_header(conn, header) do
      []      -> {conn, nil}
      [val|_] -> {conn, extract_id(String.split(val, ":"))}
    end
  end

  defp start_span({conn, [nil, _]}), do: start_span({conn, nil})
  defp start_span({conn, [_, nil]}), do: start_span({conn, nil})
  defp start_span({conn, [trace_id, span_id]}) do
    {conn, Otter.start(conn.method, trace_id, span_id)}
  end
  defp start_span({conn, _}), do: {conn, Otter.start(conn.method)}

  defp tag_span({conn, span}) do
    span = span
         |> Otter.tag("path", Enum.join(Enum.map(conn.path_info, &URI.decode/1), "/"))
         |> Otter.tag("method", conn.method)
    conn |> Conn.assign(:trace_span, span)
  end

  defp register_span(conn) do
    Conn.register_before_send(conn, fn c ->
      c.assigns[:trace_span]
      |> Otter.finish()
      c
    end)
  end

  defp extract_id(vals) when length(vals) >= 2 do
      vals
      |> Enum.take(2)
      |> Enum.map(fn(s) -> s
                        |> Integer.parse(16)
                        |> case do
                          :error -> nil
                          i      -> elem(i,0)
                        end
                     end)
  end
  defp extract_id(_), do: nil
end
