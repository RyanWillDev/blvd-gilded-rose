defmodule GildedRose.Inventory.Item.Aged do
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
