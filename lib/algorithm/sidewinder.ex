defmodule Algorithm.Sidewinder do
  @moduledoc """
  Creates a maze using sidewinder algorithm.
  """

  defstruct [:grid, :cluster]

  def generate_maze(grid) do
    context = %__MODULE__{grid: grid, cluster: []}

    %{grid: grid} =
      for row <- 0..(grid.rows - 1), column <- 0..(grid.columns - 1), reduce: context do
        acc -> carve_passages(_cell_position = {row, column}, acc)
      end

    grid
  end

  defp carve_passages(current_cell_position, %{grid: grid, cluster: cluster} = context) do
    cell = Grid.get(grid, current_cell_position)

    cluster =
      if cell.column == 0,
        do: [current_cell_position],
        else: [current_cell_position | cluster]

    if should_close_cluster?(cell, grid) do
      random_position = random(cluster)
      random_cell = Grid.get(grid, random_position)

      grid = maybe_carve_passage(:south, random_cell, grid)
      %{context | grid: grid, cluster: []}
    else
      grid = maybe_carve_passage(:east, cell, grid)
      %{context | grid: grid, cluster: cluster}
    end
  end

  defp should_close_cluster?(cell, grid) do
    at_eastern_boundary = Grid.get_neighbor(:east, cell, grid) == nil
    at_southest_boundary = Grid.get_neighbor(:south, cell, grid) == nil

    at_eastern_boundary || (!at_southest_boundary && random([true, false]))
  end

  defp maybe_carve_passage(direction, cell, grid) do
    case Grid.get_neighbor(direction, cell, grid) do
      nil -> grid
      neighbor -> Grid.link_cells(cell, neighbor, grid)
    end
  end

  defp random(list), do: Enum.random(list)
end
