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

  describe "generic items" do
    test "sell_in is decremented by 1 on update" do
      item = Item.new("generic item", 10, 10)
      gilded_rose = GildedRose.new([item])

      GildedRose.update_quality(gilded_rose)
      [updated_item] = GildedRose.items(gilded_rose)
      assert updated_item.sell_in == 9
    end

    test "quality is decremented by 1 on update" do
      item = Item.new("generic item", 10, 10)
      gilded_rose = GildedRose.new([item])

      GildedRose.update_quality(gilded_rose)
      [updated_item] = GildedRose.items(gilded_rose)
      assert updated_item.quality == 9
    end

    test "quality degrades twice as fast for expired items" do
      item = Item.new("generic item", 0, 10)
      gilded_rose = GildedRose.new([item])

      GildedRose.update_quality(gilded_rose)
      [updated_item] = GildedRose.items(gilded_rose)
      assert updated_item.quality == 8
    end

    test "quality can never be negative" do
      item = Item.new("generic item", 0, 0)
      gilded_rose = GildedRose.new([item])

      GildedRose.update_quality(gilded_rose)
      [updated_item] = GildedRose.items(gilded_rose)
      assert updated_item.quality == 0
    end
  end

  # Note: Aged items are currently denoted by name.
  # The name "Aged Brie" specifically.
  describe "aged items" do
    test "quality is incremented by 1 on update" do
      item = Item.new("Aged Brie", 10, 10)
      gilded_rose = GildedRose.new([item])

      GildedRose.update_quality(gilded_rose)
      [updated_item] = GildedRose.items(gilded_rose)
      assert updated_item.quality == 11
    end

    test "quality can never exceed 50" do
      item = Item.new("Aged Brie", 1, 50)
      gilded_rose = GildedRose.new([item])

      GildedRose.update_quality(gilded_rose)
      [updated_item] = GildedRose.items(gilded_rose)
      assert updated_item.quality == 50
    end
  end
end
