defmodule Typeri.MixProject do
  use Mix.Project

  def project do
    [
      app: :typeri,
      description: "TypeScript type generator for Peri schemas",
      version: "0.1.1",
      elixir: "~> 1.18",
      package: package(),
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

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:peri, ">= 0.3.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/vhgn/typeri"}
    ]
  end
end
