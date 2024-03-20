defmodule Algorithm.Kruskal do
  @moduledoc """
  Creates a maze using the Kruskal's algorithm.
  """

  defstruct [:grid, identity_to_cell: %{}, cell_to_identity: %{}, neighbors: []]

  def generate_maze(grid) do
    context = initialize_context(grid)

    %{grid: grid} =
      context.neighbors
      |> Enum.shuffle()
      |> Enum.reduce(context, fn [left, right], acc ->
        if can_merge?(left, right, acc),
          do: merge(left, right, acc),
          else: acc
      end)

    grid
  end

  defp initialize_context(%{rows: rows, columns: columns} = grid) do
    context = %__MODULE__{grid: grid}

    for row <- 0..(rows - 1),
        column <- 0..(columns - 1),
        cell_position = {row, column},
        reduce: context do
      acc ->
        acc
        |> initialize_identity_lookups(cell_position)
        |> add_neighbors_if_exists(:south, cell_position)
        |> add_neighbors_if_exists(:east, cell_position)
    end
  end

  defp initialize_identity_lookups(context, cell_position) do
    identity = Enum.count(context.cell_to_identity)

    cell_to_identity = Map.put(context.cell_to_identity, cell_position, identity)
    identity_to_cell = Map.put(context.identity_to_cell, identity, [cell_position])

    %{context | identity_to_cell: identity_to_cell, cell_to_identity: cell_to_identity}
  end

  defp add_neighbors_if_exists(%{grid: grid} = context, direction, cell_position) do
    cell = Grid.get(grid, cell_position)

    case Grid.get_neighbor(direction, cell, grid) do
      nil ->
        context

      %{row: row, column: column} ->
        neighbors = [cell_position, {row, column}]
        %{context | neighbors: [neighbors | context.neighbors]}
    end
  end

  def can_merge?(left, right, %{cell_to_identity: cell_to_identity}) do
    cell_to_identity[left] != cell_to_identity[right]
  end

  def merge(left, right, context) do
    grid = link_cells(left, right, context.grid)

    winner = context.cell_to_identity[left]
    loser = context.cell_to_identity[right]
    losers = context.identity_to_cell[loser] || [right]

    context =
      Enum.reduce(losers, context, fn cell, acc ->
        cell_to_identity = Map.put(acc.cell_to_identity, cell, winner)
        identity_to_cell = Map.update(acc.identity_to_cell, winner, [cell], &[cell | &1])

        %{acc | cell_to_identity: cell_to_identity, identity_to_cell: identity_to_cell}
      end)

    %{context | grid: grid, identity_to_cell: Map.delete(context.identity_to_cell, loser)}
  end

  defp link_cells(left, right, grid) do
    Grid.link_cells(Grid.get(grid, left), Grid.get(grid, right), grid)
  end
end
