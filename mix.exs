defmodule Synthex.Mixfile do
  use Mix.Project

  def project do
    [app: :synthex,
     version: "0.0.1",
     elixir: "~> 1.1",
     package: package,
     description: description,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp deps do
    []
  end

  defp description do
    "A signal synthesis library"
  end

  defp package do
    [
      maintainers: ["Michele Balistreri"],
      licenses: ["ISC"],
      links: %{"GitHub" => "https://github.com/bitgamma/synthex"}
    ]
  end
end
