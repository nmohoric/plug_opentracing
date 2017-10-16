defmodule PlugOpenTracing.Mixfile do
  use Mix.Project

  def project do
    [
      app: :plug_opentracing,
      version: "0.0.1",
      name: "PlugOpenTracing",
      source_url: "https://github.com/nmohoric/plug_opentracing",
      elixir: "~> 1.0",
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  defp description do
    """
    An Elixir Plug for adding opentracing instrumentation.
    """
  end

  defp package do
    [
      maintainers: ["Nick Mohoric"],
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/nmohoric/plug_opentracing"}
    ]
  end

  def application do
    [applications: [:plug]]
  end

  defp deps do
    [
      {:plug, "~> 1.3"},
      {:ibrowse, "~> 4.4"},
      {:otter, "~> 0.2.0"},
    ]
  end
end
