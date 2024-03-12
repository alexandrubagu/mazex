defmodule ImageGenerator do
  @doc """
  Generates an image of the maze using the erlang egd library.
  """

  defstruct [:maze, :image, :wall_color, :absolute_filename]

  @cell_size 20

  @doc """
  Generates an image of the maze.
  """
  @spec save(Grid.t(), [{:output, binary()} | {:filename, binary()}]) :: :ok
  def save(maze, opts) do
    %__MODULE__{maze: maze}
    |> set_absolute_filename(opts)
    |> set_color(opts)
    |> initialize_image()
    |> draw_walls()
    |> save_image(opts)
    |> destroy_image()
    |> return_absolute_filename()
  end

  defp set_absolute_filename(ctx, opts) do
    %{ctx | absolute_filename: Path.join([opts[:output], opts[:filename]])}
  end

  defp set_color(ctx, _opts), do: %{ctx | wall_color: :egd.color(:black)}

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

  defp save_image(ctx, opts) do
    path = Path.join([opts[:output], opts[:filename]])

    ctx.image
    |> :egd.render()
    |> :egd.save(path)

    ctx
  end

  defp destroy_image(ctx) do
    :ok = :egd.destroy(ctx.image)
    ctx
  end

  defp return_absolute_filename(ctx), do: ctx.absolute_filename
end
