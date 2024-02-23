defmodule Maze do
  @moduledoc """
  Defines a maze and its cells.
  """

  defmodule Cell do
    @moduledoc """
    Defines a cell in a maze.
    """
    @type t :: %__MODULE__{
            x: pos_integer,
            y: pos_integer,
            walls: %{
              north: boolean,
              east: boolean,
              south: boolean,
              west: boolean
            }
          }

    @enforce_keys [:x, :y]

    defstruct [:x, :y, walls: %{north: true, east: true, south: true, west: true}]

    @spec new(pos_integer(), pos_integer()) :: t()

    def new(x, y), do: %__MODULE__{x: x, y: y}

    @doc """
    Helper function to remove a wall from a cell.
    """
    @spec remove_wall(t(), :north | :east | :south | :west) :: t()
    def remove_wall(cell, :north), do: %{cell | walls: %{cell.walls | north: false}}
    def remove_wall(cell, :east), do: %{cell | walls: %{cell.walls | east: false}}
    def remove_wall(cell, :south), do: %{cell | walls: %{cell.walls | south: false}}
    def remove_wall(cell, :west), do: %{cell | walls: %{cell.walls | west: false}}

    @doc """
    Helper function to return the opposite direction of a given direction.
    """
    @spec opposite_direction(:east | :south | :west | :north) :: :east | :south | :west | :north
    def opposite_direction(:east), do: :west
    def opposite_direction(:south), do: :north
    def opposite_direction(:west), do: :east
    def opposite_direction(:north), do: :south
  end

  @typep cell_position :: {x :: pos_integer(), y :: pos_integer()}

  @type t :: %__MODULE__{
          width: pos_integer(),
          height: pos_integer(),
          lookup: %{cell_position => Cell.t()}
        }

  defstruct [:width, :height, lookup: %{}]

  @spec new(pos_integer(), pos_integer()) :: t()
  def new(width, height) do
    maze = %__MODULE__{width: width, height: height}

    for x <- 0..(width - 1),
        y <- 0..(height - 1),
        reduce: maze do
      acc -> put(acc, Cell.new(x, y))
    end
  end

  @doc """
  Adds a cell to the maze.

  Example:
    ```
    iex> maze = Maze.new(2, 2)
    iex> cell = Maze.Cell.new(0, 0)
    iex> Maze.put(maze, cell)
    %Maze{width: 2, height: 2, lookup: %{0 => %Maze.Cell{walls: %{east: true, north: true, south: true, west: true}, x: 0, y: 0}}}
    ```
  """
  def put(maze, cell), do: %{maze | lookup: Map.put(maze.lookup, {cell.x, cell.y}, cell)}

  @doc """
  Returns a cell from the maze.

  Example:
    ```
    iex> maze = Maze.new(2, 2)
    iex> Maze.get(maze, {0, 0})
    %Maze.Cell{walls: %{east: true, north: true, south: true, west: true}, x: 0, y: 0}
    ```
  """
  @spec get(t(), cell_position()) :: Cell.t()
  def get(maze, cell_position), do: Map.get(maze.lookup, cell_position)
end