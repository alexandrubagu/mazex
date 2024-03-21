defmodule Algorithm.Prim do
  @moduledoc """
  Creates a maze using the Prim's algorithm.
  """

  defstruct [:grid, :active, :costs]

  def generate_maze(grid) do
    start_at = random_cell_position(grid)

    %__MODULE__{grid: grid, active: [start_at]}
    |> initialize_costs()
    |> do_generate_maze()
  end

  defp do_generate_maze(%__MODULE__{grid: grid, active: []}), do: grid

  defp do_generate_maze(%__MODULE__{grid: grid, active: active, costs: costs} = context) do
    cell_position = lowest_cost(active, costs)
    cell = Grid.get(grid, cell_position)
    unvisited_neighbor_positions = unvisited_neighbor_positions(cell, grid)

    if Enum.empty?(unvisited_neighbor_positions) do
      do_generate_maze(%{context | active: List.delete(active, cell_position)})
    else
      neighbor_position = lowest_cost(unvisited_neighbor_positions, costs)
      neighbor = Grid.get(grid, neighbor_position)

      grid = Grid.link_cells(cell, neighbor, grid)
      do_generate_maze(%{context | grid: grid, active: [neighbor_position | active]})
    end
  end

  defp random_cell_position(%{rows: rows, columns: columns}) do
    {Enum.random(0..(rows - 1)), Enum.random(0..(columns - 1))}
  end

  defp initialize_costs(%__MODULE__{grid: grid} = context) do
    costs =
      for row <- 0..(grid.rows - 1), column <- 0..(grid.columns - 1), into: %{} do
        {{row, column}, Enum.random(0..100)}
      end

    %{context | costs: costs}
  end

  defp lowest_cost(cells, costs), do: Enum.min_by(cells, &Map.get(costs, &1))

  defp unvisited_neighbor_positions(cell, grid) do
    Enum.reduce([:east, :south, :west, :north], [], fn direction, acc ->
      neighbor = Grid.get_neighbor(direction, cell, grid)

      if neighbor && Cell.unvisited?(neighbor),
        do: [{neighbor.row, neighbor.column} | acc],
        else: acc
    end)
  end
end
