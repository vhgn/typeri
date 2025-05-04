# Typeri

TypeScript type generation from [`Peri`](https://hexdocs.pm/peri) schemas.

Find documentation at [HexDocs](https://hexdocs.pm/typeri)

## Installation

Add `typeri` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:typeri, "~> 0.1.0"}
  ]
end
```

## Usage

To use a generator and get types from `Domain.Management.Messages` module you will need to configure typeri in `config.exs` like so:

```elixir
config :typeri,
  modules: [Domain.Management.Messages], # list of modules which contain `use Typeri.Generator`
  output: "typescript", # directory where you want to output files, can also be :stdout
  file_names: :kebab_case, # preferred casing of output files, can also be :snake_case, :pascal_case, :camel_case
  file_structure: :nested # do you want module names to dictate directory names in output, if you want all the modules in one directory, use :flat
```

Then in the module `Domain.Management.Messages` use `Typeri.Generator`

```elixir
defmodule Domain.Management.Messages do
  import Peri

  use Typeri.Generator,
    types: [
      :add_user,
      :delete_user
    ]

  defschema :add_user, {:required, [
    name: {:required, :string}
  ]}

  defschema :delete_user, {:required, [
    id: {:required, :string}
  ]}
end
```

And then run:

```sh
mix typeri.gen
```

It will generate a file `typescript/domain/management/messages.ts` with the following content

```ts
export type AddUser = { name: string };
export type DeleteUser = { id: string };
```
