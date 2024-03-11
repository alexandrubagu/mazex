defmodule ImageGenerator do
  @doc """
  Generates an image of the maze using the erlang egd library.
  """

  defstruct [:maze, :image, :wall_color]

  @cell_size 20

  @doc """
  Generates an image of the maze.
  """
  @spec run(Grid.t()) :: :ok
  def run(maze) do
    %__MODULE__{maze: maze, wall_color: :egd.color(:black)}
    |> initialize_image()
    |> draw_walls()
    |> save_image()
    |> destroy_image()
  end

  defp initialize_image(%{maze: %{columns: columns, rows: rows}} = ctx) do
    image = :egd.create(columns * @cell_size + 1, rows * @cell_size + 1)

    %{ctx | image: image}
  end

  defp draw_walls(%{maze: %{rows: rows, columns: columns}} = ctx) do
    for row <- 0..(rows - 1), column <- 0..(columns - 1), reduce: ctx do
      acc -> draw_cell_walls(_cell_position = {row, column}, acc)
    end
  end

  defp draw_cell_walls(cell_position, %{maze: maze} = ctx) do
    cell = Grid.get(maze, cell_position)

    Enum.reduce(cell.walls, ctx, fn
      {direction, true}, acc -> draw_wall(acc, cell_position, direction)
      {_direction, false}, acc -> acc
    end)
  end

  defp draw_wall(ctx, _cell_position = {row, column}, :north) do
    :egd.line(
      ctx.image,
      {column * @cell_size, row * @cell_size},
      {(column + 1) * @cell_size, row * @cell_size},
      ctx.wall_color
    )

    ctx
  end

  defp draw_wall(ctx, _cell_position = {row, column}, :south) do
    :egd.line(
      ctx.image,
      {column * @cell_size, (row + 1) * @cell_size},
      {(column + 1) * @cell_size, (row + 1) * @cell_size},
      ctx.wall_color
    )

    ctx
  end

  defp draw_wall(ctx, _cell_position = {row, column}, :west) do
    :egd.line(
      ctx.image,
      {column * @cell_size, row * @cell_size},
      {column * @cell_size, (row + 1) * @cell_size},
      ctx.wall_color
    )

    ctx
  end

  defp draw_wall(ctx, _cell_position = {row, column}, :east) do
    :egd.line(
      ctx.image,
      {(column + 1) * @cell_size, row * @cell_size},
      {(column + 1) * @cell_size, (row + 1) * @cell_size},
      ctx.wall_color
    )

    ctx
  end

  defp save_image(ctx) do
    ctx.image
    |> :egd.render()
    |> :egd.save("output.png")

    ctx
  end

  defp destroy_image(ctx), do: :egd.destroy(ctx.image)
end
