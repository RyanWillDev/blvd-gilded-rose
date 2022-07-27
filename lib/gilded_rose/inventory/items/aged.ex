defmodule GildedRose.Inventory.Item.Aged do
  @moduledoc """
  Represents the class of Aged items.

  Aged items increase in quality as their sell_in value decreases. However, their value is capped at 50.
  """
  defstruct [:name, :sell_in, :quality]

  def new(name, sell_in, quality) when quality > 50, do: new(name, sell_in, 50)

  def new(name, sell_in, quality) do
    struct(__MODULE__, name: name, sell_in: sell_in, quality: quality)
  end

  defimpl GildedRose.Inventory.Item do
    def update(item) do
      # Taking the min of the increment or 50 prevents quality from exceeding 50
      %{item | sell_in: item.sell_in - 1, quality: min(item.quality + 1, 50)}
    end
  end
end
