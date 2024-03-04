defmodule Algorithm.BinaryTree do
  @moduledoc """
  Creates a maze using the binary tree algorithm.

  The algorithm starts at the top-left cell and iterates through each cell in the maze
  and randomly decides whether to carve a passage to the cell to the east or the cell to the south.
  """

  def run(maze) do
    for x <- 0..(maze.rows - 1), y <- 0..(maze.columns - 1), reduce: maze do
      acc -> carve_passages(_cell_position = {x, y}, acc)
    end
  end

  defp carve_passages(cell_position, maze) do
    cell = Maze.get(maze, cell_position)

    case random_neighbor(cell, maze) do
      nil -> maze
      {direction, neighbor} -> update_cell_walls(cell, neighbor, direction, maze)
    end
  end

  defp random_neighbor(cell, maze) do
    neighbors =
      [
        east: {cell.row, cell.column + 1},
        south: {cell.row + 1, cell.column}
      ]
      |> Enum.filter(fn {_direction, neighbor} -> is_valid_neighbor?(neighbor, maze) end)
      |> Enum.map(fn {direction, neighbor} -> {direction, Maze.get(maze, neighbor)} end)

    if not Enum.empty?(neighbors), do: Enum.random(neighbors)
  end

  defp is_valid_neighbor?({row, column}, maze) do
    row >= 0 and row < maze.rows and column >= 0 and column < maze.columns
  end

  defp update_cell_walls(cell, neighbor, direction, maze) do
    updated_cell = Maze.Cell.remove_wall(cell, direction)

    neighbor_opposite_direction = Maze.Cell.opposite_direction(direction)
    updated_neighbor = Maze.Cell.remove_wall(neighbor, neighbor_opposite_direction)

    maze
    |> Maze.put(updated_cell)
    |> Maze.put(updated_neighbor)
  end
end
