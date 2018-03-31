require 'test_helper'

class LineItemJobTest < ActiveSupport::TestCase
  let(:payload) { DrinkCommandHelper.generate_line_item }
  let(:line_item_id) { payload.dig(:line_item_id) }
  let(:item) { LineItem.create!(
    user: users(:one), dc_uuid: line_item_id, payload: payload) }

  it "processes line item" do
    item.user.comps.create!(amount_in_cents: 2000)
    LineItemJob.new.perform( item.id )

    LineItem.find( item.id ).tap do |item|
      assert item.processed?
      refute item.user_transaction.nil?
    end
  end

  it "processes line time w/ user nil" do
    item = LineItem.create!(dc_uuid: line_item_id, payload: payload)
    LineItemJob.new.perform( item.id )

    LineItem.find( item.id ).tap do |item|
      assert item.pending?
      assert item.user_transaction.nil?
    end
  end

end
