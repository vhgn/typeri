defmodule TyperiTest do
  use ExUnit.Case
  doctest Typeri

  test "greets the world" do
    schema =
      {:required,
       %{
         name: {:required, :string},
         age: :integer
       }}

    assert Typeri.to_type(schema) == "{ name: string; age: null | number }"
  end
end
