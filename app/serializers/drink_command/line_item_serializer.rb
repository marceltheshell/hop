class DrinkCommand::LineItemSerializer < ApplicationSerializer
  attr_reader :item

  def initialize( item, options ={} )
    @item = item
    super(options)
  end

  def data
    Hash(
      line_item_id: item.dc_uuid,
      status: item.status
    )
  end
end
