defmodule Algorithm.Wilson do
  @moduledoc """
  Generates a maze using the Wilson algorithm.
  """

  defstruct [:grid, :unvisited, :path, :current]

  def generate_maze(grid) do
    %__MODULE__{grid: grid}
    |> initialize_unvisited_cell_positions()
    |> visit_random_unvisited_cell_position()
    |> do_generate_maze()
  end

  defp do_generate_maze(%{unvisited: unvisited, grid: grid} = context) do
    if not_empty?(unvisited) do
      context
      |> choose_random_unvisited_cell()
      |> build_unvisited_cell_path()
      |> visit_cells_in_path()
      |> do_generate_maze()
    else
      grid
    end
  end

  defp choose_random_unvisited_cell(%{unvisited: unvisited} = context) do
    random_unvisited_cell_position = random(unvisited)
    %{context | current: random_unvisited_cell_position, path: [random_unvisited_cell_position]}
  end

  defp build_unvisited_cell_path(%{current: current, unvisited: unvisited, path: path} = context) do
    if unvisited?(current, unvisited) do
      cell = random_neighbor_position(current, context.grid)

      path =
        case cell_position_in_path(cell, path) do
          nil -> path ++ [cell]
          position -> get_path_until_position(path, position + 1)
        end

      build_unvisited_cell_path(%{context | current: cell, path: path})
    else
      %{context | path: path}
    end
  end

  defp visit_cells_in_path(%{path: path} = context) do
    for index <- 0..(Enum.count(path) - 2), reduce: context do
      acc ->
        from_cell = Grid.get(acc.grid, Enum.at(path, index))
        to_cell = Grid.get(acc.grid, Enum.at(path, index + 1))

        grid = Grid.link_cells(from_cell, to_cell, acc.grid)
        unvisited_cell_positions = visit_cell_position(acc.unvisited, Enum.at(path, index))

        %{acc | grid: grid, unvisited: unvisited_cell_positions}
    end
  end

  def initialize_unvisited_cell_positions(%{grid: %{rows: rows, columns: columns}} = context) do
    unvisited_cell_positions =
      for x <- 0..(rows - 1), y <- 0..(columns - 1), into: MapSet.new() do
        {x, y}
      end

    %{context | unvisited: unvisited_cell_positions}
  end

  defp visit_random_unvisited_cell_position(%{unvisited: unvisited} = context) do
    random_cell_position = random(unvisited)
    unvisited_cell_positions = visit_cell_position(unvisited, random_cell_position)

    %{context | unvisited: unvisited_cell_positions}
  end

  defp random_neighbor_position(cell_position, grid) do
    cell = Grid.get(grid, cell_position)

    possible_neighbors =
      Enum.reduce([:east, :south, :west, :north], [], fn direction, acc ->
        neighbor = Grid.get_neighbor(direction, cell, grid)
        if neighbor, do: [neighbor | acc], else: acc
      end)

    random_neighbor = random(possible_neighbors)

    {random_neighbor.row, random_neighbor.column}
  end

  # Path helper functions
  defp cell_position_in_path(position, path), do: Enum.find_index(path, &(&1 == position))
  defp get_path_until_position(path, position), do: Enum.take(path, position)

  # Visit helper functions
  defp unvisited?(cell_position, unvisited), do: MapSet.member?(unvisited, cell_position)
  defp visit_cell_position(unvisited, cell_position), do: MapSet.delete(unvisited, cell_position)

  # MapSet helper functions
  defp not_empty?(mapset), do: Enum.any?(mapset)
  defp random(%MapSet{map: map}) when map_size(map) == 0, do: nil
  defp random(mapset), do: Enum.random(mapset)
end
