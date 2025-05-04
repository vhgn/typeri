defmodule Mix.Tasks.Typeri.Gen do
  @moduledoc """
  Mix task for `mix typeri.gen [output]`
  """
  @requirements ["app.config"]

  use Mix.Task

  @shortdoc "Generates types into the specified output directory"
  def run([output_dir]) do
    Typeri.Generator.run(output_dir: output_dir)
  end

  def run([]) do
    Typeri.Generator.run()
  end
end
