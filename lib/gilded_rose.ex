defmodule GildedRose do
  use Agent
  alias GildedRose.Item, as: LegacyItem
  alias GildedRose.Inventory.Item
  alias GildedRose.Inventory.Item.{Aged, BackstagePass, Conjured, Generic, Legendary}

  def new(inventory \\ default_inventory()) do
    {:ok, agent} =
      Agent.start_link(fn ->
        inventory
      end)

    agent
  end

  def items(agent), do: Agent.get(agent, & &1)

  def update_quality(agent) do
    Agent.get_and_update(agent, fn inventory ->
      updated_inventory =
        Enum.map(inventory, fn item ->
          case item do
            # LegacyItem and legacy_update/1 are left in place until such a time
            # we can be sure that they can be removed.
            #
            # As it stands now, there are no references to this code other than
            # this one.
            %LegacyItem{} ->
              legacy_update(item)

            _ ->
              Item.update(item)
          end
        end)

      {:ok, updated_inventory}
    end)
  end

  defp legacy_update(item) do
    item =
      cond do
        item.name != "Aged Brie" && item.name != "Backstage passes to a TAFKAL80ETC concert" ->
          if item.quality > 0 do
            if item.name != "Sulfuras, Hand of Ragnaros" do
              %{item | quality: item.quality - 1}
            else
              item
            end
          else
            item
          end

        true ->
          cond do
            item.quality < 50 ->
              item = %{item | quality: item.quality + 1}

              cond do
                item.name == "Backstage passes to a TAFKAL80ETC concert" ->
                  item =
                    cond do
                      item.sell_in < 11 ->
                        cond do
                          item.quality < 50 ->
                            %{item | quality: item.quality + 1}

                          true ->
                            item
                        end

                      true ->
                        item
                    end

                  cond do
                    item.sell_in < 6 ->
                      cond do
                        item.quality < 50 ->
                          %{item | quality: item.quality + 1}

                        true ->
                          item
                      end

                    true ->
                      item
                  end

                true ->
                  item
              end

            true ->
              item
          end
      end

    item =
      cond do
        item.name != "Sulfuras, Hand of Ragnaros" ->
          %{item | sell_in: item.sell_in - 1}

        true ->
          item
      end

    item =
      cond do
        item.sell_in < 0 ->
          cond do
            item.name != "Aged Brie" ->
              cond do
                item.name != "Backstage passes to a TAFKAL80ETC concert" ->
                  cond do
                    item.quality > 0 ->
                      cond do
                        item.name != "Sulfuras, Hand of Ragnaros" ->
                          %{item | quality: item.quality - 1}

                        true ->
                          item
                      end

                    true ->
                      item
                  end

                true ->
                  %{item | quality: item.quality - item.quality}
              end

            true ->
              cond do
                item.quality < 50 ->
                  %{item | quality: item.quality + 1}

                true ->
                  item
              end
          end

        true ->
          item
      end

    item
  end

  defp default_inventory do
    [
      Generic.new("+5 Dexterity Vest", 10, 20),
      Aged.new("Aged Brie", 2, 0),
      Generic.new("Elixir of the Mongoose", 5, 7),
      Legendary.new("Sulfuras, Hand of Ragnaros"),
      BackstagePass.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
      Conjured.new("Conjured Mana Cake", 3, 6)
    ]
  end
end
