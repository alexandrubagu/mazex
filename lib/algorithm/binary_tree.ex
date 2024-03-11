defmodule Algorithm.BinaryTree do
  @moduledoc """
  Creates a maze using the binary tree algorithm.

  The algorithm starts at the top-left cell and iterates through each cell in the maze
  and randomly decides whether to carve a passage to the cell to the east or the cell to the south.
  """

  def run(grid) do
    for x <- 0..(grid.rows - 1), y <- 0..(grid.columns - 1), reduce: grid do
      acc -> carve_passage(_cell_position = {x, y}, acc)
    end
  end

  defp carve_passage(cell_position, grid) do
    possible_directions =
      Enum.filter([:east, :south], &Grid.get_neighbor(&1, cell_position, grid))

    case random_direction(possible_directions) do
      nil -> grid
      direction -> Grid.carve_passage(direction, cell_position, grid)
    end
  end

  defp random_direction([]), do: nil
  defp random_direction(directions), do: Enum.random(directions)
end
