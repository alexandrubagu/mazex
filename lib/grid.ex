defmodule Grid do
  @moduledoc """
  Defines a grid and its cells.
  """

  @type t :: %__MODULE__{
          rows: pos_integer(),
          columns: pos_integer(),
          lookup: %{cell_position => Cell.t()}
        }

  @typep direction :: :east | :south | :west | :north
  @typep cell_position :: {row :: pos_integer(), column :: pos_integer()}

  defstruct [:rows, :columns, lookup: %{}]

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

    @typep direction :: :east | :south | :west | :north

    defstruct [:row, :column, walls: %{}]

    @doc """
    Creates a new cell.
    """
    @spec new(pos_integer(), pos_integer()) :: t()
    def new(row, column) do
      %__MODULE__{
        row: row,
        column: column,
        walls: %{north: true, east: true, south: true, west: true}
      }
    end

    @doc """
    Helper function to remove a wall from a cell.
    """
    @spec remove_wall(t(), direction()) :: t()
    def remove_wall(cell, :north), do: %{cell | walls: %{cell.walls | north: false}}
    def remove_wall(cell, :east), do: %{cell | walls: %{cell.walls | east: false}}
    def remove_wall(cell, :south), do: %{cell | walls: %{cell.walls | south: false}}
    def remove_wall(cell, :west), do: %{cell | walls: %{cell.walls | west: false}}
  end

  @doc """
  Creates a new grid.
  """
  @spec new(pos_integer(), pos_integer()) :: t()
  def new(rows, columns) do
    grid = %__MODULE__{rows: rows, columns: columns}

    for row <- 0..(rows - 1), column <- 0..(columns - 1), reduce: grid do
      acc -> put(acc, Cell.new(row, column))
    end
  end

  @doc """
  Adds a cell to the grid.
  """
  def put(grid, cell), do: %{grid | lookup: Map.put(grid.lookup, {cell.row, cell.column}, cell)}

  @doc """
  Returns a cell from the grid.
  """
  @spec get(t(), cell_position()) :: Cell.t()
  def get(grid, cell_position), do: Map.get(grid.lookup, cell_position)

  @doc """
  Returns a neighbor of current cell position in the given direction.
  """
  @spec get_neighbor(direction(), cell_position() | Cell.t(), t()) :: Cell.t() | nil
  def get_neighbor(direction, %Cell{row: row, column: column}, grid),
    do: get_neighbor(direction, {row, column}, grid)

  def get_neighbor(direction, {row, column} = _current_cell, grid) do
    case direction do
      :east -> get(grid, {row, column + 1})
      :south -> get(grid, {row + 1, column})
      :west -> get(grid, {row, column - 1})
      :north -> get(grid, {row - 1, column})
    end
  end

  @doc """
  Carves a passage between two cells in the grid by removing the walls between them.
  The function accepts a direction, the current cell position, and the grid and returns the updated grid.
  """
  @spec carve_passage(direction(), cell_position(), t()) :: t()
  def carve_passage(direction, current_cell_position, grid) do
    current_cell = get(grid, current_cell_position)
    updated_cell = Cell.remove_wall(current_cell, direction)

    neighbor = get_neighbor(direction, current_cell_position, grid)
    neighbor_opposite_direction = opposite_direction(direction)
    updated_neighbor = Cell.remove_wall(neighbor, neighbor_opposite_direction)

    grid
    |> put(updated_cell)
    |> put(updated_neighbor)
  end

  defp opposite_direction(:east), do: :west
  defp opposite_direction(:south), do: :north
  defp opposite_direction(:west), do: :east
  defp opposite_direction(:north), do: :south
end
