defmodule Typeri.Generator do
  @app :typeri

  defmacro __using__(opts) do
    types = Keyword.get(opts, :types, [])

    quote do
      def __typeris__() do
        unquote(types)
      end

      def __typeri_file__() do
        slice_last = String.length("Elixir.")
        name = Atom.to_string(__MODULE__) |> String.slice(slice_last..-1//1)

        unquote do
          opts
        end
        |> Keyword.get(:file, name <> ".ts")
      end
    end
  end

  def run(opts \\ []) do
    output = get_config(:output, opts, :stdout)

    get_config(:modules, opts, [])
    |> Enum.map(&module_to_file/1)
    |> Enum.map(&output(&1, output))
  end

  defp output({name, content}, :return) do
    {name, content}
  end

  defp output({name, content}, :stdout) do
    IO.puts("// #{name}" <> content)
    {name, content}
  end

  defp output({name, content}, dir) when is_binary(dir) do
    Path.join(dir, name)
    |> File.write!(content)

    {name, content}
  end

  defp get_config(key, overrides, default) do
    Keyword.get(overrides, key, Application.get_env(@app, key, default))
  end

  defp module_to_file(module) do
    types = apply(module, :__typeris__, [])

    content =
      Enum.map(types, fn schema_name ->
        schema = apply(module, :get_schema, [schema_name])
        Typeri.to_definition(schema_name, schema)
      end)
      |> Enum.join("\n")

    file = apply(module, :__typeri_file__, [])

    {file, content}
  end
end
