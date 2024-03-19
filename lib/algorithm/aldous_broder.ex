defmodule Algorithm.AldousBroder do
  @doc """
  Walks the grid using the Aldous-Broder algorithm.
  """

  def generate_maze(grid) do
    unvisited_cells_count = grid.rows * grid.columns
    random_cell = get_random_cell(grid)

    do_generate_maze(grid, random_cell, unvisited_cells_count - 1)
  end

  defp do_generate_maze(grid, _random_cell, 0), do: grid

  defp do_generate_maze(grid, cell, unvisited_cells_count) do
    random_neighbor = random_neighbor(cell, grid)

    if Cell.unvisited?(random_neighbor) do
      grid = Grid.link_cells(cell, random_neighbor, grid)

      random_neighbor = refresh_cell(random_neighbor, grid)
      do_generate_maze(grid, random_neighbor, unvisited_cells_count - 1)
    else
      random_neighbor = refresh_cell(random_neighbor, grid)
      do_generate_maze(grid, random_neighbor, unvisited_cells_count)
    end
  end

  defp get_random_cell(%{rows: rows, columns: columns} = grid) do
    random_row = Enum.random(0..(rows - 1))
    random_column = Enum.random(0..(columns - 1))

    Grid.get(grid, {random_row, random_column})
  end

  defp random_neighbor(cell, grid) do
    possible_neighbors =
      Enum.reduce([:east, :south, :west, :north], [], fn direction, acc ->
        neighbor = Grid.get_neighbor(direction, cell, grid)
        if neighbor, do: [neighbor | acc], else: acc
      end)

    random(possible_neighbors)
  end

  defp refresh_cell(cell, grid), do: Grid.get(grid, {cell.row, cell.column})

  defp random([]), do: nil
  defp random(directions), do: Enum.random(directions)
end
