defmodule TyperiGenTest do
  use ExUnit.Case
  doctest Typeri
  doctest Casing, import: true

  test "generates types" do
    expected =
      {"test-schema.ts",
       [
         "export type Customer = { name: string };",
         "export type Product = { description: null | string; price: number };"
       ]
       |> Enum.join("\n")}

    assert [expected] == Typeri.Generator.run(modules: [TestSchema], output: :return)
  end
end

defmodule TestSchema do
  import Peri

  use Typeri.Generator,
    types: [:customer, :product]

  defschema(
    :customer,
    {:required,
     [
       name: {:required, :string}
     ]}
  )

  defschema(
    :product,
    {:required,
     [
       description: :string,
       price: {:required, :integer}
     ]}
  )
end
