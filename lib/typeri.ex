defmodule Typeri do
  @moduledoc """
  Documentation for `Typeri`.
  """

  @not_implemented "Not implemented"

  @doc """
  Creates a type definition with name (provided atom or string will be transformed to PascalCase)

  ## Examples

      iex> Typeri.to_definition(:product, {:required, %{ price: {:required, :integer}, description: :string }})
      "type Product = { description: null | string; price: number }"

  """
  @spec to_definition(name :: String.t() | atom(), schema :: Peri.schema()) :: String.t()
  def to_definition(name, schema) do
    [
      "type #{transform_name(name)} =",
      to_type(schema)
    ]
    |> Enum.join(" ")
  end

  defp transform_name(name) when is_binary(name) do
    name
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
  end

  defp transform_name(name) when is_atom(name) do
    transform_name(Atom.to_string(name))
  end

  @doc """
  Creates a type from schema

  ## Examples

      iex> Typeri.to_type({:required, :boolean})
      "boolean"

      iex> Typeri.to_type({:required, %{ name: {:required, :string}, age: :integer }})
      "{ name: string; age: null | number }"

  """
  @spec to_type(schema :: Peri.schema()) :: String.t()
  def to_type(schema) do
    to_type(schema, [])
  end

  defp to_type(:any, opts), do: convert("any", opts)
  defp to_type(:atom, _opts), do: raise(@not_implemented)
  defp to_type(:boolean, opts), do: convert("boolean", opts)
  defp to_type(:map, _opts), do: raise(@not_implemented)
  defp to_type(:pid, _opts), do: raise(@not_implemented)

  defp to_type({:either, {left, right}}, opts), do: to_union([left, right], opts)
  defp to_type({:oneof, schemas}, opts), do: to_union(schemas, opts)
  defp to_type({:required, schema}, []), do: to_type(schema, required: true)
  defp to_type({:enum, literals}, opts), do: literals |> Enum.map(&to_literal/1) |> to_union(opts)
  defp to_type({:list, schema}, opts), do: convert("Array<#{to_type(schema, [])}>", opts)

  defp to_type({:map, schema}, opts), do: convert("Record<string, #{to_type(schema, [])}", opts)

  defp to_type({:map, schema_key, schema_value}, opts),
    do: convert("Record<#{to_type(schema_key, [])}, #{to_type(schema_value, [])}", opts)

  defp to_type({:tuple, schemas}, opts),
    do:
      schemas
      |> Enum.map(&to_type(&1, opts))
      |> Enum.join(", ")
      |> then(&convert("[" <> &1 <> "]", opts))

  defp to_type({:literal, literal}, opts), do: convert(to_literal(literal), opts)

  defp to_type(:time, opts), do: convert("Date", opts)
  defp to_type(:date, opts), do: convert("Date", opts)
  defp to_type(:datetime, opts), do: convert("Date", opts)
  defp to_type(:naive_datetime, opts), do: convert("Date", opts)

  defp to_type(:string, opts), do: convert("string", opts)
  defp to_type({:string, _}, _opts), do: raise(@not_implemented)

  defp to_type(:integer, opts), do: convert("number", opts)
  defp to_type({:integer, _}, _opts), do: raise(@not_implemented)
  defp to_type(:float, opts), do: convert("number", opts)
  defp to_type({:float, _}, _opts), do: raise(@not_implemented)
  defp to_type({schema, :default}, opts), do: to_type(schema, opts)
  defp to_type({schema, :transform}, opts), do: to_type(schema, opts)
  defp to_type({:custom, _}, opts), do: convert("unknown", opts)
  defp to_type({:custom, _, _}, opts), do: convert("unknown", opts)

  defp to_type(schema, opts) when is_map(schema) do
    schema
    |> Map.to_list()
    |> to_type(opts)
  end

  defp to_type(schema, opts) when is_list(schema) do
    defs =
      schema
      |> Enum.map(fn {name, type} -> "#{name}: #{to_type(type, [])}" end)
      |> Enum.join("; ")

    ["{", defs, "}"] |> Enum.join(" ") |> convert(opts)
  end

  defp to_union(schemas, opts) do
    schemas
    |> Enum.map(&to_type(&1, opts))
    |> Enum.join(" | ")
  end

  defp to_literal(term) when is_binary(term), do: "\"#{term}\""
  defp to_literal(term) when is_number(term), do: "#{term}"
  defp to_literal(term), do: raise("Literals for type #{term} is not implemented")

  defp convert(code, opts) do
    is_required = Keyword.get(opts, :required, false)

    if is_required do
      code
    else
      "null | #{code}"
    end
  end
end
