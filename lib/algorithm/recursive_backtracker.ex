defmodule Algorithm.RecursiveBacktracker do
  @moduledoc """
  Creates a maze using the recursive backtracker algorithm.
  """

  defstruct [:grid, stack: []]

  def generate_maze(grid) do
    start_at = random_cell_position(grid)

    %__MODULE__{grid: grid, stack: [start_at]}
    |> do_generate_maze()
  end

  defp do_generate_maze(%__MODULE__{grid: grid, stack: []}), do: grid

  defp do_generate_maze(%__MODULE__{grid: grid, stack: stack} = context) do
    [current_positionposition | stack_after_pop] = stack

    current_cell = Grid.get(grid, current_positionposition)
    unvisited_neighbor_positions = unvisited_neighbor_positions(current_cell, grid)

    if Enum.empty?(unvisited_neighbor_positions) do
      do_generate_maze(%{context | stack: stack_after_pop})
    else
      random_neighbor_position = Enum.random(unvisited_neighbor_positions)
      random_neighbor = Grid.get(grid, random_neighbor_position)

      grid = Grid.link_cells(current_cell, random_neighbor, grid)
      do_generate_maze(%{context | grid: grid, stack: [random_neighbor_position | stack]})
    end
  end

  defp random_cell_position(%{rows: rows, columns: columns}) do
    {Enum.random(0..(rows - 1)), Enum.random(0..(columns - 1))}
  end

  defp unvisited_neighbor_positions(cell, grid) do
    Enum.reduce([:east, :south, :west, :north], [], fn direction, acc ->
      neighbor = Grid.get_neighbor(direction, cell, grid)

      if neighbor && Cell.unvisited?(neighbor),
        do: [{neighbor.row, neighbor.column} | acc],
        else: acc
    end)
  end
end
