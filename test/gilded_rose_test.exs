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
      [%{} | _] = GildedRose.items(gilded_rose)
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

  # Note: Legendary items are currently denoted by name.
  # The name "Sulfuras, Hand of Ragnaros" specifically.
  describe "legendary items" do
    test "sell_in remains unchanged on update" do
      item = Item.new("Sulfuras, Hand of Ragnaros", 10, 80)
      gilded_rose = GildedRose.new([item])

      GildedRose.update_quality(gilded_rose)
      [updated_item] = GildedRose.items(gilded_rose)
      assert updated_item.sell_in == item.sell_in
    end

    test "quality never decreases" do
      item = Item.new("Sulfuras, Hand of Ragnaros", 10, 80)
      gilded_rose = GildedRose.new([item])

      for _ <- 0..10 do
        GildedRose.update_quality(gilded_rose)
        [updated_item] = GildedRose.items(gilded_rose)
        assert updated_item.quality == item.quality
      end
    end
  end

  # Note: Backstage passes are currently denoted by name.
  # The name "Backstage passes to a TAFKAL80ETC concert" specifically.
  describe "backstage passes" do
    test "quality is set to 0 after sell_in has passed ie: is sell_in <= 0" do
      item = Item.new("Backstage passes to a TAFKAL80ETC concert", 0, 10)
      gilded_rose = GildedRose.new([item])

      GildedRose.update_quality(gilded_rose)
      [updated_item] = GildedRose.items(gilded_rose)
      assert updated_item.quality == 0
    end

    test "quality increases by 1 on each update when there are more than 10 days until expiration" do
      item = Item.new("Backstage passes to a TAFKAL80ETC concert", 100, 10)
      gilded_rose = GildedRose.new([item])

      GildedRose.update_quality(gilded_rose)
      [updated_item] = GildedRose.items(gilded_rose)
      assert updated_item.quality == 11
    end

    test "quality increases by 2 when there are 10 or less days until expiration" do
      item = Item.new("Backstage passes to a TAFKAL80ETC concert", 10, 10)
      gilded_rose = GildedRose.new([item])

      GildedRose.update_quality(gilded_rose)
      [updated_item] = GildedRose.items(gilded_rose)
      assert updated_item.quality == 12
    end

    test "quality increases by 3 when there are 5 or less days until expiration" do
      item = Item.new("Backstage passes to a TAFKAL80ETC concert", 5, 10)
      gilded_rose = GildedRose.new([item])

      GildedRose.update_quality(gilded_rose)
      [updated_item] = GildedRose.items(gilded_rose)
      assert updated_item.quality == 13
    end
  end
end
