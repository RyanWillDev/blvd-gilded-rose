defmodule GildedRose.Inventory.Item.Conjured do
  defstruct [:name, :sell_in, :quality]

  def new(name, sell_in, quality) do
    struct(__MODULE__, name: name, sell_in: sell_in, quality: quality)
  end

  defimpl GildedRose.Inventory.Item do
    def update(item) do
      quality_decrease = if item.sell_in > 0, do: 2, else: 4

      # Taking the max of the decrease or 0 prevents us from setting quality to a negative
      %{item | sell_in: item.sell_in - 1, quality: max(item.quality - quality_decrease, 0)}
    end
  end
end
