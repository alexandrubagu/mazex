defmodule ImageGenerator do
  @doc """
  Generates an image of the maze using the erlang egd library.
  """

  defstruct [:maze, :image, :wall_color]

  @cell_size 20

  @doc """
  Generates an image of the maze.
  """
  @spec run(Maze.t()) :: :ok
  def run(maze) do
    %__MODULE__{maze: maze, wall_color: :egd.color(:black)}
    |> initialize_image()
    |> draw_walls()
    |> save_image()
    |> destroy_image()
  end

  defp initialize_image(%{maze: %{width: width, height: height}} = ctx) do
    image = :egd.create(width * @cell_size + 1, height * @cell_size + 1)

    %{ctx | image: image}
  end

  defp draw_walls(%{maze: %{width: width, height: height}} = ctx) do
    for x <- 0..(width - 1), y <- 0..(height - 1), reduce: ctx do
      acc -> draw_cell_walls(_cell_position = {x, y}, acc)
    end
  end

  defp draw_cell_walls(cell_position, %{maze: maze} = ctx) do
    cell = Maze.get(maze, cell_position)

    Enum.reduce(cell.walls, ctx, fn
      {direction, true}, acc -> draw_wall(acc, cell_position, direction)
      {_direction, false}, acc -> acc
    end)
  end

  defp draw_wall(ctx, _cell_position = {x, y}, :north) do
    :egd.line(
      ctx.image,
      {x * @cell_size, y * @cell_size,},
      {x * @cell_size, (y + 1) * @cell_size,},
      ctx.wall_color
    )

    ctx
  end

  defp draw_wall(ctx, _cell_position = {x, y}, :south) do
    :egd.line(
      ctx.image,
      {(x + 1) * @cell_size, y * @cell_size,},
      {(x + 1) * @cell_size, (y + 1) * @cell_size},
      ctx.wall_color
    )

    ctx
  end

  defp draw_wall(ctx, _cell_position = {x, y}, :west) do
    :egd.line(
      ctx.image,
      {x * @cell_size, y * @cell_size},
      {(x + 1) * @cell_size, y * @cell_size},
      ctx.wall_color
    )

    ctx
  end

  defp draw_wall(ctx, _cell_position = {x, y}, :east) do
    :egd.line(
      ctx.image,
      {x * @cell_size, (y + 1) * @cell_size},
      {(x + 1) * @cell_size, (y + 1) * @cell_size},
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
