defmodule CellTest do
  use ExUnit.Case

  describe "new/1" do
    test "creates a new cell" do
      assert %Cell{row: 1, column: 2, walls: %{north: true, east: true, south: true, west: true}} =
               Cell.new(1, 2)
    end
  end

  describe "unvisited?" do
    test "returns true if the cell is unvisited" do
      assert Cell.unvisited?(%Cell{
               row: 1,
               column: 1,
               walls: %{north: true, east: true, south: true, west: true}
             })
    end

    test "returns false if the cell is visited" do
      refute Cell.unvisited?(%Cell{
               row: 1,
               column: 1,
               walls: %{north: false, east: true, south: true, west: true}
             })

      refute Cell.unvisited?(%Cell{
               row: 1,
               column: 1,
               walls: %{north: true, east: false, south: true, west: true}
             })

      refute Cell.unvisited?(%Cell{
               row: 1,
               column: 1,
               walls: %{north: true, east: true, south: false, west: true}
             })

      refute Cell.unvisited?(%Cell{
               row: 1,
               column: 1,
               walls: %{north: true, east: true, south: true, west: false}
             })
    end
  end

  describe "remove_wall/2" do
    setup _, do: {:ok, cell: Cell.new(1, 1)}

    test "removes the wall in the given direction", %{cell: cell} do
      assert %Cell{
               walls: %{north: false, east: true, south: true, west: true}
             } = Cell.remove_wall(cell, :north)

      assert %Cell{walls: %{north: true, east: false, south: true, west: true}} =
               Cell.remove_wall(cell, :east)

      assert %Cell{walls: %{north: true, east: true, south: false, west: true}} =
               Cell.remove_wall(cell, :south)

      assert %Cell{walls: %{north: true, east: true, south: true, west: false}} =
               Cell.remove_wall(cell, :west)
    end
  end

  describe "detect_direction/2" do
    test "detects the direction of the second cell relative to the first cell" do
      static_cell = %Cell{row: 1, column: 1}

      moving_cell = %Cell{row: 0, column: 1}
      assert :north = Cell.detect_direction(static_cell, moving_cell)

      moving_cell = %Cell{row: 1, column: 2}
      assert :east = Cell.detect_direction(static_cell, moving_cell)

      moving_cell = %Cell{row: 2, column: 1}
      assert :south = Cell.detect_direction(static_cell, moving_cell)

      moving_cell = %Cell{row: 1, column: 0}
      assert :west = Cell.detect_direction(static_cell, moving_cell)
    end

    test "raises an error if the cells are not adjacent" do
      cell1 = %Cell{row: 0, column: 0}
      cell2 = %Cell{row: 3, column: 3}

      assert_raise ArgumentError, "Cannot detect direction", fn ->
        Cell.detect_direction(cell1, cell2)
      end
    end
  end

  describe "opposite_direction/1" do
    test "returns the opposite direction" do
      assert :west = Cell.opposite_direction(:east)
      assert :north = Cell.opposite_direction(:south)
      assert :east = Cell.opposite_direction(:west)
      assert :south = Cell.opposite_direction(:north)
    end
  end
end
