defmodule GildedRose.Inventory.Item.Legendary do
  defstruct [:name, :quality]

  def new(name) do
    struct(__MODULE__, name: name, quality: 80)
  end

  defimpl GildedRose.Inventory.Item do
    def update(item), do: item
  end
end
