defmodule PlugOpenTracingTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias Plug.Conn.Status

  test "missing trace header results in new span" do
    connection = conn(:get, "/test-path")
    response = TestApp.call(connection, [])

    assert response.status == Status.code(:ok)
    assert response.resp_body != ""
  end

  test "bad trace header results in new span" do
    connection = conn(:get, "/test-path") |> put_req_header("uber-trace-id", "1234")
    response = TestApp.call(connection, [])

    assert response.status == Status.code(:ok)
    assert response.resp_body != ""
  end

  test "valid trace header results in span with those ids" do
    connection = conn(:get, "/test-path") |> put_req_header("uber-trace-id", "6a5c63925e01051b:150b1b1adcde6f4:6a5c63925e01051b:1")
    response = TestApp.call(connection, [])

    assert response.status == Status.code(:ok)
    assert response.resp_body == "7664110146171241755"
  end

  test "invalid hex trace header results in usable span" do
    connection = conn(:get, "/test-path") |> put_req_header("uber-trace-id", "6a5x63925t01051b:150b1p1adcdq6f4:6a5c63925e01051b:1")
    response = TestApp.call(connection, [])

    assert response.status == Status.code(:ok)
    assert response.resp_body == "1701"
  end

  test "empty trace header results in new span" do
    connection = conn(:get, "/test-path") |> put_req_header("uber-trace-id", "")
    response = TestApp.call(connection, [])

    assert response.status == Status.code(:ok)
    assert response.resp_body != ""
  end

  test "just some colons results in new span" do
    connection = conn(:get, "/test-path") |> put_req_header("uber-trace-id", "::::")
    response = TestApp.call(connection, [])

    assert response.status == Status.code(:ok)
    assert response.resp_body != ""
  end
end
