defmodule Algorithm.BinaryTree do
  @moduledoc """
  Creates a maze using the binary tree algorithm.
  """

  def generate_maze(grid) do
    for row <- 0..(grid.rows - 1), column <- 0..(grid.columns - 1), reduce: grid do
      acc -> carve_passage(_cell_position = {row, column}, acc)
    end
  end

  defp carve_passage(cell_position, grid) do
    cell = Grid.get(grid, cell_position)

    possible_neighbors =
      Enum.reduce([:east, :south], [], fn direction, acc ->
        neighbor = Grid.get_neighbor(direction, cell, grid)
        if neighbor, do: [neighbor | acc], else: acc
      end)

    case random_neighbor(possible_neighbors) do
      nil -> grid
      neighbor -> Grid.link_cells(cell, neighbor, grid)
    end
  end

  defp random_neighbor([]), do: nil
  defp random_neighbor(list), do: Enum.random(list)
end
