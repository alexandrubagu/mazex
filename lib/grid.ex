defmodule Grid do
  @moduledoc """
  Defines a grid and its cells.
  """

  @type cell :: %{
          row: non_neg_integer(),
          column: non_neg_integer(),
          walls: %{
            north: boolean(),
            east: boolean(),
            south: boolean(),
            west: boolean()
          }
        }

  @type direction :: :east | :south | :west | :north
  @type cell_position :: {row :: non_neg_integer(), column :: non_neg_integer()}

  @type t :: %__MODULE__{
          rows: pos_integer(),
          columns: pos_integer(),
          lookup: %{cell_position() => cell()}
        }

  defstruct [:rows, :columns, lookup: %{}]

  @doc """
  Creates a new grid.
  """
  @spec new(pos_integer(), pos_integer()) :: t()
  def new(rows, columns) do
    grid = %__MODULE__{rows: rows, columns: columns}

    for row <- 0..(rows - 1), column <- 0..(columns - 1), reduce: grid do
      acc -> put(acc, new_cell(row, column))
    end
  end

  defp new_cell(row, column) do
    %{row: row, column: column, walls: %{north: true, east: true, south: true, west: true}}
  end

  @doc """
  Adds a cell to the grid.
  """
  def put(grid, cell), do: %{grid | lookup: Map.put(grid.lookup, {cell.row, cell.column}, cell)}

  @doc """
  Returns a cell from the grid or nil if the cell does not exist.
  """
  @spec get(t(), cell_position()) :: Cell.t()
  def get(grid, cell_position), do: Map.get(grid.lookup, cell_position)

  @doc """
  Returns a neighbor of current cell position in the given direction or nil if the neighbor does not exist.
  """
  @spec get_neighbor(direction(), cell_position(), t()) :: cell() | nil
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
    updated_cell = remove_wall(current_cell, direction)

    neighbor = get_neighbor(direction, current_cell_position, grid)
    neighbor_opposite_direction = opposite_direction(direction)
    updated_neighbor = remove_wall(neighbor, neighbor_opposite_direction)

    grid
    |> put(updated_cell)
    |> put(updated_neighbor)
  end

  defp opposite_direction(:east), do: :west
  defp opposite_direction(:south), do: :north
  defp opposite_direction(:west), do: :east
  defp opposite_direction(:north), do: :south

  defp remove_wall(cell, :north), do: %{cell | walls: %{cell.walls | north: false}}
  defp remove_wall(cell, :east), do: %{cell | walls: %{cell.walls | east: false}}
  defp remove_wall(cell, :south), do: %{cell | walls: %{cell.walls | south: false}}
  defp remove_wall(cell, :west), do: %{cell | walls: %{cell.walls | west: false}}
end
