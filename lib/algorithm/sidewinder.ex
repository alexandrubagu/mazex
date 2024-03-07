defmodule Sidewinder do
  @moduledoc """
  Creates a maze using sidewinder algorithm.

  """

  defstruct [:grid, cluster: []]

  def run(grid) do
    context = %__MODULE__{grid: grid, cluster: []}

    for x <- 0..(grid.rows - 1), y <- 0..(grid.columns - 1), reduce: context do
      acc -> carve_passages(_cell_position = {x, y}, acc)
    end
  end

  defp carve_passages(cell_position, context) do
    cell = Grid.get(context.grid, cell_position)
    cluster = [cell | context.cluster]

    if should_close_cluster?(cell_position, context.grid) do
      cluster
      |> pick_random()
      |> carve_passages_at_south(context)
      |> update_grid(context)
      |> reset_cluster()
    else
      cell
      |> carve_passage_at_east(context)
      |> update_grid()
    end
  end

  defp should_close_cluster?(cell_position, grid) do
    has_eastern_cell?(cell_position, grid) ||
      (!has_south_cell?(cell_position, grid) && pick_random([0, 1]) == 0)
  end

  defp has_eastern_cell?({row, column}, grid), do: !!Grid.get({row, column + 1}, grid)
  defp has_south_cell?({row, column}, grid), do: !!Grid.get({row + 1, column}, grid)

  defp carve_passages_at_south(cell, %{grid: grid} = _context) do
    south_neighbor = {}
  end

  defp update_grid(grid, context), do: %{context | grid: grid}
  defp reset_cluster(context), do: %{context | cluster: []}
  defp pick_random(list), do: list |> Enum.shuffle() |> Enum.at(0)
end
