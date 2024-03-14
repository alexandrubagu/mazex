defmodule Algorithm.BinaryTree do
  @moduledoc """
  Creates a maze using the binary tree algorithm.
  """

  def generate_maze(grid) do
    for x <- 0..(grid.rows - 1), y <- 0..(grid.columns - 1), reduce: grid do
      acc -> carve_passage(_cell_position = {x, y}, acc)
    end
  end

  defp carve_passage(current_cell_position, grid) do
    possible_neighbors =
      [:east, :south]
      |> Enum.map(&Grid.get_neighbor(&1, current_cell_position, grid))
      |> Enum.reject(&is_nil/1)

    case random_neighbor(possible_neighbors) do
      nil -> grid
      %{row: row, column: column} -> Grid.link_cells(current_cell_position, {row, column}, grid)
    end
  end

  defp random_neighbor([]), do: nil
  defp random_neighbor(list), do: Enum.random(list)
end
