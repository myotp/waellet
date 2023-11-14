defmodule Waellet.MixProject do
  use Mix.Project

  def project do
    [
      app: :waellet,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # No dependencies  :)
  defp deps do
    []
  end
end
