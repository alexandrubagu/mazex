defmodule Algorithm.BinaryTree do
  @moduledoc """
  Creates a maze using the binary tree algorithm.

  The algorithm starts at the top-left cell and iterates through each cell in the maze
  and randomly decides whether to carve a passage to the cell to the east or the cell to the south.
  """

  def run(grid) do
    for x <- 0..(grid.rows - 1), y <- 0..(grid.columns - 1), reduce: grid do
      acc -> carve_passages(_cell_position = {x, y}, acc)
    end
  end

  defp carve_passages(cell_position, grid) do
    cell = Grid.get(grid, cell_position)

    case random_neighbor(cell, grid) do
      nil -> grid
      {direction, neighbor} -> update_cell_walls(cell, neighbor, direction, grid)
    end
  end

  defp random_neighbor(cell, grid) do
    neighbors =
      [
        east: {cell.row, cell.column + 1},
        south: {cell.row + 1, cell.column}
      ]
      |> Enum.filter(fn {_direction, neighbor} -> is_valid_neighbor?(neighbor, grid) end)
      |> Enum.map(fn {direction, neighbor} -> {direction, Grid.get(grid, neighbor)} end)

    if not Enum.empty?(neighbors), do: Enum.random(neighbors)
  end

  defp is_valid_neighbor?({row, column}, grid) do
    row >= 0 and row < grid.rows and column >= 0 and column < grid.columns
  end

  defp update_cell_walls(cell, neighbor, direction, grid) do
    updated_cell = Grid.Cell.remove_wall(cell, direction)

    neighbor_opposite_direction = Grid.Cell.opposite_direction(direction)
    updated_neighbor = Grid.Cell.remove_wall(neighbor, neighbor_opposite_direction)

    grid
    |> Grid.put(updated_cell)
    |> Grid.put(updated_neighbor)
  end
end
