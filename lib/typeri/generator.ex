defmodule Typeri.Generator do
  require Logger

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
        |> Keyword.get(:file, name)
      end
    end
  end

  def run(opts \\ []) do
    output_type = get_config(:output, opts, :stdout)
    file_structure = get_config(:file_structure, opts, :nested)
    file_naming = get_config(:file_naming, opts, :kebab_case)

    get_config(:modules, opts, [])
    |> Enum.map(&module_to_file/1)
    |> Enum.map(
      &output(&1,
        output_type: output_type,
        file_structure: file_structure,
        file_naming: file_naming
      )
    )
  end

  defp output({name, content},
         output_type: :return,
         file_structure: file_structure,
         file_naming: file_naming
       ) do
    alias Casing

    delimiter =
      if file_structure == :flat do
        ""
      else
        "/"
      end

    file =
      name
      |> String.split(".")
      |> Enum.map(&Casing.transform(&1, :pascal_case, file_naming))
      |> Enum.join(delimiter)

    {file <> ".ts", content}
  end

  defp output(name, [{:output_type, :stdout} | opts]) do
    {file, content} = output(name, [{:output_type, :return} | opts])
    IO.puts("// #{file}\n" <> content)
    {file, content}
  end

  defp output(name, [{:output_type, dir} | opts]) when is_binary(dir) do
    {file, content} = output(name, [{:output_type, :return} | opts])
    path = Path.join(dir, file)
    Logger.info("Writing to path #{path}")

    Path.dirname(path)
    |> tap(&Logger.info("Creating path #{&1}"))
    |> File.mkdir_p!()

    path
    |> File.write!(content)

    {path, content}
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
