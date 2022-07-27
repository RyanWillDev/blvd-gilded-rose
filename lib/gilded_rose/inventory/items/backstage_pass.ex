defmodule GildedRose.Inventory.Item.BackstagePass do
  defstruct [:name, :sell_in, :quality]

  def new(name, sell_in, quality) when quality > 50, do: new(name, sell_in, 50)

  def new(name, sell_in, quality) do
    struct(__MODULE__, name: name, sell_in: sell_in, quality: quality)
  end

  defimpl GildedRose.Inventory.Item do
    def update(item) do
      quality_increase =
        cond do
          item.sell_in > 10 ->
            1

          item.sell_in > 5 ->
            2

          item.sell_in > 0 ->
            3

          true ->
            # Setting the increase to negative the current value will 0 it out for us
            -item.quality
        end

      # Taking the min of the increase or 50 prevents quality from exceeding 50
      %{item | sell_in: item.sell_in - 1, quality: min(item.quality + quality_increase, 50)}
    end
  end
end
