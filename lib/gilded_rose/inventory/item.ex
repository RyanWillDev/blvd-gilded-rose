defprotocol GildedRose.Inventory.Item do
  @moduledoc """
  A generic interface to update an item.

  To implement a new item, you must do the following.

  1. Create a new item class. See lib/gilded_rose/inventory/items/ for examples.
  2. Implement the Item protocol described here for the new class of items.
  """
  @type t() :: t()

  @spec update(t()) :: t()
  def update(item)
end
