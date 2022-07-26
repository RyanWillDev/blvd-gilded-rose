defmodule GildedRoseTest do
  use ExUnit.Case
  doctest GildedRose

  alias GildedRose.Item

  describe "interface specification" do
    test "accepts a list as starting inventory" do
      item = Item.new("item", 10, 10)
      gilded_rose = GildedRose.new([item])
      assert [^item] = GildedRose.items(gilded_rose)
    end

    test "returns :ok on successful update" do
      gilded_rose = GildedRose.new()
      [%Item{} | _] = GildedRose.items(gilded_rose)
      assert :ok == GildedRose.update_quality(gilded_rose)
    end
  end
end
