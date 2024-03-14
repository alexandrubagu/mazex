defmodule Algorithm.Sidewinder do
  @moduledoc """
  Creates a maze using sidewinder algorithm.
  """

  defstruct [:grid, cluster: []]

  def generate_maze(grid) do
    context = %__MODULE__{grid: grid, cluster: []}

    %{grid: grid} =
      for x <- 0..(grid.rows - 1), y <- 0..(grid.columns - 1), reduce: context do
        acc -> carve_passages(_cell_position = {x, y}, acc)
      end

    grid
  end

  defp carve_passages(cell_position, %{grid: grid, cluster: cluster} = context) do
    cluster = [cell_position | cluster]

    if should_close_cluster?(cell_position, grid) do
      random_position = random_element(cluster)
      grid = maybe_carve_passage(:south, random_position, grid)

      %{context | grid: grid, cluster: _reset_cluster = []}
    else
      grid = maybe_carve_passage(:east, cell_position, grid)

      %{context | grid: grid}
    end
  end

  defp should_close_cluster?(cell_position, grid) do
    neighbor_at_east = !!Grid.get_neighbor(:east, cell_position, grid)
    neighbor_at_south = !!Grid.get_neighbor(:south, cell_position, grid)

    not neighbor_at_east || (neighbor_at_south && random_element([0, 1]) == 0)
  end

  defp maybe_carve_passage(direction, cell_position, grid) do
    case Grid.get_neighbor(direction, cell_position, grid) do
      nil -> grid
      %{row: row, column: column} -> Grid.link_cells(cell_position, {row, column}, grid)
    end
  end

  defp random_element(list), do: Enum.random(list)
end
