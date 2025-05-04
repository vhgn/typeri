defmodule TyperiTest do
  use ExUnit.Case
  doctest Typeri

  test "converts objects" do
    schema =
      {:required,
       %{
         name: {:required, :string},
         age: :integer
       }}

    assert Typeri.to_type(schema) == "{ name: string; age: null | number }"
  end

  test "converts unions" do
    for {schema, definition} <- [
          {{:required, {:either, {:integer, :string}}}, "number | string"},
          {{:required,
            {:oneof,
             [
               [
                 type: {:required, {:literal, "success"}},
                 data: {:required, {:list, {:required, :string}}}
               ],
               [type: {:required, {:literal, "error"}}, message: :string]
             ]}},
           "{ type: \"success\"; data: Array<string> } | { type: \"error\"; message: null | string }"}
        ] do
      assert Typeri.to_type(schema) == definition
    end
  end
end
