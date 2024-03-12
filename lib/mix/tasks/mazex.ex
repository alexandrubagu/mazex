defmodule Mix.Tasks.Mazex do
  use Mix.Task

  @shortdoc "Generate mazes using different algorithms and rendering them as images"

  @supported_algorithms %{
    "binary_tree" => Algorithm.BinaryTree,
    "sidewinder" => Algorithm.Sidewinder
  }

  @moduledoc """

  Mazex is a tool for generating mazes using different algorithms and rendering them as png images.

      # mix mazex --rows=10 --columns=15 --algorithm=sidewinder --output=/tmp --filename=maze.png

  ## Options
      --rows             # Number of rows for the maze
      --columns          # Number of columns for the maze
      --algorithm        # One of the following algorithms: #{@supported_algorithms |> Map.keys() |> Enum.join(", ")}
      --output           # Output folder if not given it will use the current folder as output folder
      --filename         # File name to be used for generated maze image, if not given it will use the maze_<current_timestamp>.png.
  """

  @switches [
    rows: :integer,
    columns: :integer,
    algorithm: :string,
    output: :string,
    filename: :string
  ]

  @impl true
  def run(args) do
    {given_opts, []} = OptionParser.parse!(args, strict: @switches)

    case given_opts do
      [] -> run_help()
      _ -> validate_required_opts_and_generate_maze(given_opts)
    end
  end

  def run_help(), do: Mix.shell().cmd("mix help mazex")

  defp validate_required_opts_and_generate_maze(given_opts) do
    given_opts
    |> add_optional_opts_if_missing()
    |> validate_required_opts!()
    |> generate_maze()
  end

  defp add_optional_opts_if_missing(opts) do
    opts
    |> Keyword.put_new_lazy(:output, fn -> File.cwd!() end)
    |> Keyword.put_new_lazy(:filename, fn -> "maze_#{timestamp()}.png" end)
  end

  defp timestamp(), do: DateTime.utc_now() |> DateTime.to_unix()

  defp validate_required_opts!(opts) do
    validate_rows!(opts[:rows])
    validate_columns!(opts[:columns])
    validate_algorithm!(opts[:algorithm])
    validate_output_directory!(opts[:output])

    opts
  end

  defp validate_rows!(rows) when is_integer(rows) and rows > 0, do: :ok
  defp validate_rows!(_rows), do: Mix.raise("Invalid rows, expected a positive integer")

  defp validate_columns!(columns) when is_integer(columns) and columns > 0, do: :ok
  defp validate_columns!(_columns), do: Mix.raise("Invalid columns, expected a positive integer")

  defp validate_algorithm!(algorithm) when is_map_key(@supported_algorithms, algorithm), do: :ok

  defp validate_algorithm!(_algorithm) do
    supported_algorithm_names = @supported_algorithms |> Map.keys() |> Enum.join(", ")
    Mix.raise("Invalid algorithm, expected one of the following: #{supported_algorithm_names}")
  end

  defp validate_output_directory!(output), do: File.mkdir_p!(output)

  defp generate_maze(opts) do
    grid = Grid.new(opts[:rows], opts[:columns])
    algorithm = @supported_algorithms[opts[:algorithm]]
    maze = algorithm.generate_maze(grid)
    image = ImageGenerator.save(maze, opts)

    Mix.shell().info("Maze generated at #{image}")
  end
end
