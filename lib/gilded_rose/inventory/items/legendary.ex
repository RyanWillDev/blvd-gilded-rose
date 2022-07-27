defmodule GildedRose.Inventory.Item.Legendary do
  @moduledoc """
  Represents the Legendary class of items.

  Legendary items never have to be sold and never decrease in quality.
  """
  defstruct [:name, :quality]

  def new(name) do
    struct(__MODULE__, name: name, quality: 80)
  end

  defimpl GildedRose.Inventory.Item do
    def update(item), do: item
  end
end
