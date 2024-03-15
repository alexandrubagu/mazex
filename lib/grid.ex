defmodule Grid do
  @moduledoc """
  Defines a grid and its cells.
  """

  @type direction :: :east | :south | :west | :north
  @type cell_position :: {row :: non_neg_integer(), column :: non_neg_integer()}

  @type t :: %__MODULE__{
          rows: pos_integer(),
          columns: pos_integer(),
          lookup: %{cell_position() => Cell.t()}
        }

  defstruct [:rows, :columns, lookup: %{}]

  @doc """
  Creates a new grid.
  """
  def new(rows, columns) do
    grid = %__MODULE__{rows: rows, columns: columns}

    for row <- 0..(rows - 1), column <- 0..(columns - 1), reduce: grid do
      acc -> put(acc, Cell.new(row, column))
    end
  end

  @doc """
  Adds a cell to the grid.
  """
  @spec put(t(), Cell.t()) :: t()
  def put(grid, %Cell{row: row, column: column} = cell) do
    %{grid | lookup: Map.put(grid.lookup, {row, column}, cell)}
  end

  @doc """
  Returns a cell from the grid or nil if the cell does not exist.
  """
  @spec get(t(), cell_position()) :: Cell.t() | nil
  def get(grid, cell_position), do: Map.get(grid.lookup, cell_position)

  @doc """
  Returns a neighbor of current cell position in the given direction or nil if the neighbor does not exist.
  """
  @spec get_neighbor(direction(), Cell.t(), t()) :: Cell.t() | nil
  def get_neighbor(direction, %Cell{row: row, column: column}, grid) do
    case direction do
      :east -> get(grid, {row, column + 1})
      :south -> get(grid, {row + 1, column})
      :west -> get(grid, {row, column - 1})
      :north -> get(grid, {row - 1, column})
    end
  end

  @doc """
  Links two cells in the grid by removing the walls between them.
  """
  @spec link_cells(Cell.t(), Cell.t(), t()) :: t()
  def link_cells(current_cell, neighbor_cell, grid) do
    direction = Cell.detect_direction(current_cell, neighbor_cell)
    neighbor_opposite_direction = Cell.opposite_direction(direction)

    updated_cell = Cell.remove_wall(current_cell, direction)
    updated_neighbor = Cell.remove_wall(neighbor_cell, neighbor_opposite_direction)

    grid
    |> put(updated_cell)
    |> put(updated_neighbor)
  end
end
