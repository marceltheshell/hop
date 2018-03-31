class LineItemJob < ApplicationJob

  #
  # 
  #
  def perform( line_item_id )
    with_db_connection do
      item = ::LineItem.find(line_item_id)
      item.process! if item
    end
  end
end
