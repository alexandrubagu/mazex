defmodule GridTest do
  use ExUnit.Case

  describe "new/1" do
    test "creates a grid with the given dimensions" do
      assert %Grid{rows: 2, columns: 3} = Grid.new(2, 3)
    end
  end

  describe "get_neighbor/3" do
    setup _, do: {:ok, grid: Grid.new(3, 3)}

    test "returns the proper neighbor in the given direction", %{grid: grid} do
      cell = %Cell{row: 1, column: 1}

      assert %Cell{row: 1, column: 2} = Grid.get_neighbor(:east, cell, grid)
      assert %Cell{row: 2, column: 1} = Grid.get_neighbor(:south, cell, grid)
      assert %Cell{row: 1, column: 0} = Grid.get_neighbor(:west, cell, grid)
      assert %Cell{row: 0, column: 1} = Grid.get_neighbor(:north, cell, grid)
    end

    test "returns nil if the neighbor does not exist", %{grid: grid} do
      refute Grid.get_neighbor(:north, %Cell{row: 0, column: 0}, grid)
      refute Grid.get_neighbor(:south, %Cell{row: 3, column: 3}, grid)
      refute Grid.get_neighbor(:east, %Cell{row: 0, column: 3}, grid)
      refute Grid.get_neighbor(:west, %Cell{row: 3, column: 0}, grid)
      refute Grid.get_neighbor(:north, %Cell{row: 100, column: 100}, grid)
    end
  end

  describe "link_cells/3" do
    setup _, do: {:ok, grid: Grid.new(3, 3)}

    test "links two cells by removing the walls between them when neighbor is at east", %{
      grid: grid
    } do
      static_cell = %Cell{row: 1, column: 1}

      moving_cell = %Cell{row: 0, column: 1}
      grid = Grid.link_cells(static_cell, moving_cell, grid)

      assert %Cell{walls: %{north: false, east: true, south: true, west: true}} =
               Grid.get(grid, {1, 1})

      assert %Cell{walls: %{north: true, east: true, south: false, west: true}} =
               Grid.get(grid, {0, 1})

      moving_cell = %Cell{row: 1, column: 2}
      grid = Grid.link_cells(static_cell, moving_cell, grid)

      assert %Cell{walls: %{north: true, east: false, south: true, west: true}} =
               Grid.get(grid, {1, 1})

      assert %Cell{walls: %{north: true, east: true, south: true, west: false}} =
               Grid.get(grid, {1, 2})

      moving_cell = %Cell{row: 2, column: 1}
      grid = Grid.link_cells(static_cell, moving_cell, grid)

      assert %Cell{walls: %{north: true, east: true, south: false, west: true}} =
               Grid.get(grid, {1, 1})

      assert %Cell{walls: %{north: false, east: true, south: true, west: true}} =
               Grid.get(grid, {2, 1})

      moving_cell = %Cell{row: 1, column: 0}
      grid = Grid.link_cells(static_cell, moving_cell, grid)

      assert %Cell{walls: %{north: true, east: true, south: true, west: false}} =
               Grid.get(grid, {1, 1})

      assert %Cell{walls: %{north: true, east: false, south: true, west: true}} =
               Grid.get(grid, {1, 0})
    end

    test "raises if the cells are not neighbors", %{grid: grid} do
      cell1 = %Cell{row: 1, column: 1}
      cell2 = %Cell{row: 0, column: 0}

      assert_raise ArgumentError, "Cannot detect direction", fn ->
        Grid.link_cells(cell1, cell2, grid)
      end
    end
  end
end
