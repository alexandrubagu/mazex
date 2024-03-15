defmodule Cell do
  @moduledoc """
  Defines a cell in a grid.
  """
  @type t :: %__MODULE__{
          row: non_neg_integer(),
          column: non_neg_integer(),
          walls: %{
            north: boolean,
            east: boolean,
            south: boolean,
            west: boolean
          }
        }

  @typep direction :: :east | :south | :west | :north

  defstruct [:row, :column, walls: %{north: true, east: true, south: true, west: true}]

  @doc """
  Creates a new cell.
  """
  @spec new(pos_integer(), pos_integer()) :: t()
  def new(row, column), do: %__MODULE__{row: row, column: column}

  @doc """
  Checks if the cell is unvisited.
  """
  @spec unvisited?(t()) :: boolean()
  def unvisited?(%__MODULE__{} = cell) do
    case cell do
      %{walls: %{north: true, east: true, south: true, west: true}} -> true
      _ -> false
    end
  end

  @doc """
  Helper function to remove a wall from a cell.
  """
  @spec remove_wall(t(), direction()) :: t()
  def remove_wall(cell, :north), do: %{cell | walls: %{cell.walls | north: false}}
  def remove_wall(cell, :east), do: %{cell | walls: %{cell.walls | east: false}}
  def remove_wall(cell, :south), do: %{cell | walls: %{cell.walls | south: false}}
  def remove_wall(cell, :west), do: %{cell | walls: %{cell.walls | west: false}}

  @doc """
  Detects the direction of second cell relative to the first cell.
  """
  @spec detect_direction(t(), t()) :: direction() | no_return()
  def detect_direction(%__MODULE__{} = cell1, %__MODULE__{} = cell2),
    do: do_detect_direction({cell1.row, cell1.column}, {cell2.row, cell2.column})

  defp do_detect_direction({same_x, y1}, {same_x, y2}) when y1 > y2, do: :west
  defp do_detect_direction({same_x, y1}, {same_x, y2}) when y1 < y2, do: :east
  defp do_detect_direction({x1, same_y}, {x2, same_y}) when x1 > x2, do: :north
  defp do_detect_direction({x1, same_y}, {x2, same_y}) when x1 < x2, do: :south
  defp do_detect_direction(_, _), do: raise(ArgumentError, message: "Cannot detect direction")

  @doc """
  Returns the opposite direction of the given direction.
  """
  @spec opposite_direction(direction()) :: direction()
  def opposite_direction(:east), do: :west
  def opposite_direction(:south), do: :north
  def opposite_direction(:west), do: :east
  def opposite_direction(:north), do: :south
end
