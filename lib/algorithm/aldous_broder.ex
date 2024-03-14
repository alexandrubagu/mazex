defmodule Algorithm.AldousBroder do
  @doc """
  Walks the grid using the Aldous-Broder algorithm.
  """

  def generate_maze(grid) do
    unvisited_cells_count = grid.rows * grid.columns
    random_cell_position = get_random_cell_position(grid)

    do_generate_maze(grid, random_cell_position, unvisited_cells_count - 1)
  end

  defp do_generate_maze(grid, _current_cell_position, 0), do: grid

  defp do_generate_maze(grid, current_cell_position, unvisited_cells_count) do
    random_neighbor = random_neighbor(current_cell_position, grid)
    random_neighbor_position = {random_neighbor.row, random_neighbor.column}

    if unvisited_neighbor?(random_neighbor) do
      grid = Grid.link_cells(current_cell_position, random_neighbor_position, grid)

      do_generate_maze(grid, random_neighbor_position, unvisited_cells_count - 1)
    else
      do_generate_maze(grid, random_neighbor_position, unvisited_cells_count)
    end
  end

  defp get_random_cell_position(%{rows: rows, columns: columns} = _grid) do
    {Enum.random(0..(rows - 1)), Enum.random(0..(columns - 1))}
  end

  defp random_neighbor(cell_position, grid) do
    possible_neighbors_with_directions =
      Enum.reduce([:east, :south, :west, :north], [], fn direction, acc ->
        case Grid.get_neighbor(direction, cell_position, grid) do
          nil -> acc
          neighbor -> [neighbor | acc]
        end
      end)

    random(possible_neighbors_with_directions)
  end

  defp unvisited_neighbor?(%{walls: walls} = _cell) do
    case walls do
      %{north: true, east: true, south: true, west: true} -> true
      _ -> false
    end
  end

  defp random([]), do: nil
  defp random(directions), do: Enum.random(directions)
end
