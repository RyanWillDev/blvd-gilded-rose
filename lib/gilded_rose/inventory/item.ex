defprotocol GildedRose.Inventory.Item do
  @moduledoc """
  A generic interface to update an item.
  """
  @type t() :: t()

  @spec update(t()) :: t()
  def update(item)
end
