defmodule Grid do
  @moduledoc """
  Defines a grid and its cells.
  """

  defmodule Cell do
    @moduledoc """
    Defines a cell in a grid.
    """
    @type t :: %__MODULE__{
            row: pos_integer,
            column: pos_integer,
            walls: %{
              north: boolean,
              east: boolean,
              south: boolean,
              west: boolean
            }
          }

    @enforce_keys [:row, :column]

    defstruct [:row, :column, walls: %{north: true, east: true, south: true, west: true}]

    @spec new(pos_integer(), pos_integer()) :: t()

    def new(row, column), do: %__MODULE__{row: row, column: column}

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

  @typep cell_position :: {row :: pos_integer(), column :: pos_integer()}

  @type t :: %__MODULE__{
          rows: pos_integer(),
          columns: pos_integer(),
          lookup: %{cell_position => Cell.t()}
        }

  defstruct [:rows, :columns, lookup: %{}]

  @doc ~S"""
  Creates a new grid.

  ## Example:

      iex> Grid.new(2, 2)
      %Grid{rows: 2, columns: 2, lookup: %{
        {0, 0} => %Cell{row: 0, column: 0, walls: %{east: true, north: true, south: true, west: true}},
        {0, 1} => %Cell{row: 0, column: 1, walls: %{east: true, north: true, south: true, west: true}},
        {1, 0} => %Cell{row: 1, column: 0, walls: %{east: true, north: true, south: true, west: true}},
        {1, 1} => %Cell{row: 1, column: 1, walls: %{east: true, north: true, south: true, west: true}}
      }}
  """
  @spec new(pos_integer(), pos_integer()) :: t()
  def new(rows, columns) do
    grid = %__MODULE__{rows: rows, columns: columns}

    for row <- 0..(rows - 1),
        column <- 0..(columns - 1),
        reduce: grid do
      acc -> put(acc, Cell.new(row, column))
    end
  end

  @doc """
  Adds a cell to the grid.

  ## Example:
    iex> grid = Grid.new(2, 2)
    iex> cell = Grid.Cell.new(0, 0)
    iex> Grid.put(grid, cell)
    %Grid{width: 2, height: 2, lookup: %{
      {0, 0} => %Maze.Cell{row: 0, column: 0, walls: %{east: true, north: true, south: true, west: true}}
    }}
  """
  def put(grid, cell), do: %{grid | lookup: Map.put(grid.lookup, {cell.row, cell.column}, cell)}

  @doc """
  Returns a cell from the grid.

  ## Example:

    iex> grid = Grid.new(2, 2)
    iex> Grid.get(grid, {0, 0})
    %Grid.Cell{walls: %{east: true, north: true, south: true, west: true}, row: 0, column: 0}
  """
  @spec get(t(), cell_position()) :: Cell.t()
  def get(grid, cell_position), do: Map.get(grid.lookup, cell_position)
end
