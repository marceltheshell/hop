require 'test_helper'

class LineItemTest < ActiveSupport::TestCase
  let(:user) { users(:one) }
  let(:payload) { DrinkCommandHelper.generate_line_item }
  let(:line_item_id) { payload.dig(:line_item_id) }
  let(:session_token) { user.rfid }

  it "saves" do
    assert LineItem.create!(
      user: user,
      dc_uuid: line_item_id,
      payload: payload)
  end

  describe "drink command id" do
    it "is required" do
      line = LineItem.new
      refute line.valid?
      assert_match /can't be blank/i, line.errors[:dc_uuid].to_sentence
    end

    it "no duplicates" do
      data = Hash(
        user: user, dc_uuid: line_item_id, payload: payload)
      LineItem.create!(data)

      ex = assert_raises(ActiveRecord::RecordInvalid) do
        LineItem.create!(data)
      end
      assert_match /already been taken/, ex.message
    end
  end

  describe "#process!" do
    let(:item) { LineItem.from_payload(user, payload) }

    it "succeeds users' balance is sufficient" do
      item.user.comps.create!(amount_in_cents: 2000)
      assert_equal true, item.process!
      assert item.processed?
      assert item.user_transaction.present?
    end

    it "fails when users' balance is insufficient" do
      assert_raises(ActiveRecord::RecordInvalid){ item.process! }
      assert item.failed?
      assert item.user_transaction.nil?
    end

    it "does not reprocess 'processed' items" do
      item.user.comps.create!(amount_in_cents: 2000)
      assert_equal true, item.process!
      assert_equal false, item.process!
      assert item.user_transaction.present?
    end

    it "transaction has created_at from payload" do
      item.user.comps.create!(amount_in_cents: 2000)
      payload_created_at = Time.parse( item.payload.dig('created_at') )

      assert_equal true, item.process!
      assert_equal payload_created_at, item.user_transaction.created_at
    end

    it "transaction has description from payload" do
      item.user.comps.create!(amount_in_cents: 2000)

      assert_equal true, item.process!
      assert_equal "Blue Moon", item.user_transaction.description
    end

    it "only processes PRODUCT types" do
      user.comps.create!(amount_in_cents: 2000)
      payload = DrinkCommandHelper.generate_line_item(
        amount: 1200, type: "CASH")
      item = LineItem.from_payload(user, payload)

      assert_equal "CASH", item.payload.dig('account_type')
      assert item.pending?

      item.process!
      assert item.processed?
      assert item.user_transaction.nil?
    end

    it "does not process when user is nil" do
      item = LineItem.from_payload(nil, payload)

      assert_equal false, item.process!
      assert item.pending?
    end

  end

  describe "#from_payload" do
    it "with valid user" do
      assert LineItem.from_payload(user, payload).pending?
    end

    it "enqueue LineItemJob" do
      assert_difference ->{ LineItemJob.jobs.size } do
        LineItem.from_payload(user, payload)
      end
    end

    it "returns existing line item" do
      item1 = LineItem.from_payload(user, payload)
      item2 = LineItem.from_payload(user, payload)
      assert_equal item2, item1
    end

    it "succeeds w/ nil user" do
      assert LineItem.from_payload(nil, payload).pending?

      assert_equal 1, LineItem.where(user_id: nil).count
      assert LineItem.where(user_id: nil).first.user_transaction.nil?
    end

  end
end
