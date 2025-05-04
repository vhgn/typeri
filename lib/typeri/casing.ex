defmodule Casing do
  @moduledoc """
  Transform from one casing to another

  ## Examples

    iex> "user-name" |> from(:kebab_case) |> to(:pascal_case)
    "UserName"
  """

  @doc """
  Transform from one casing to another

  ## Examples

    iex> "user-name" |> transform(:kebab_case, :pascal_case)
    "UserName"

    iex> "TestCase" |> transform(:pascal_case, :snake_case)
    "test_case"

    iex> "TestCase" |> transform(:pascal_case, :camel_case)
    "testCase"
  """
  def transform(sentence, from_casing, to_casing) do
    sentence |> from(from_casing) |> to(to_casing)
  end

  def from(sentence, :snake_case) do
    sentence |> String.split("_")
  end

  def from(sentence, :kebab_case) do
    sentence |> String.split("-")
  end

  def from(sentence, :camel_case) do
    sentence |> from(:pascal_case)
  end

  def from(sentence, :pascal_case) do
    sentence
    |> String.graphemes()
    |> Enum.chunk_while(
      [],
      fn
        char, [] ->
          {:cont, [char]}

        char, acc ->
          if char =~ ~r/[A-Z]/ do
            {:cont, Enum.reverse(acc), [char]}
          else
            {:cont, [char | acc]}
          end
      end,
      fn acc -> {:cont, Enum.reverse(acc), []} end
    )
    |> Enum.map(&List.to_string/1)
    |> Enum.map(&decapitalize/1)
  end

  defp decapitalize("") do
    ""
  end

  defp decapitalize(word) do
    [first | others] =
      word
      |> String.graphemes()

    String.downcase(first) <> List.to_string(others)
  end

  def to(words, :kebab_case) do
    words |> Enum.join("-")
  end

  def to(words, :snake_case) do
    words |> Enum.join("_")
  end

  def to(words, :pascal_case) do
    words |> Enum.map(&String.capitalize/1) |> Enum.join("")
  end

  def to(words, :camel_case) do
    to(words, :pascal_case) |> decapitalize()
  end
end
