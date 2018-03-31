require 'test_helper'

class Api::V1::DrinkCommandTest < ActionDispatch::IntegrationTest
  let(:user) { users(:two) }
  let(:rfid) { user.rfid }
  let(:charge_params) { Hash( charge: Hash(amount_in_cents: 500) ) }
  let(:line_item_params) { Hash(line_item: DrinkCommandHelper.generate_line_item) }

  describe "customer details" do
    it "success using payment url" do
      get api_v1_drink_command_payment_path( rfid ), headers: authenticated_header
      assert_response :success
    end

    it "success using customer url" do
      get api_v1_drink_command_customer_path( rfid ), headers: authenticated_header
      assert_response :success
    end

    it "credit limit equals balance when less than default limit" do
      get api_v1_drink_command_customer_path( rfid ), headers: authenticated_header
      parsed_response.dig('data').tap do |json|
        assert_equal json.dig('balance_in_cents'), json.dig('credit_limit_in_cents')
      end
    end

    it "fails when missing payment details" do
      user.payment_method.destroy
      get api_v1_drink_command_payment_path( rfid ), headers: authenticated_header
      assert_response :not_acceptable
    end

    it "raises error when payment is expired" do
      user.payment_method.update!(expires_at: 1.year.ago)
      get api_v1_drink_command_payment_path( rfid ), headers: authenticated_header
      assert_response :not_acceptable
    end

    it "raises error when rfid is not found" do
      get api_v1_drink_command_payment_path( '1234' ), headers: authenticated_header
      assert_response :not_found
    end
  end

  describe "adding value to HOP account" do
    it "posts a charge" do
      VCR.use_cassette("bridgepay-charge") do
        post api_v1_drink_command_charge_path( rfid ), params: charge_params, headers: authenticated_header
      end

      assert_response :created
    end

    it "posts a failed charge" do
      VCR.use_cassette("bridgepay-invalid-card") do
        post api_v1_drink_command_charge_path( rfid ), params: charge_params, headers: authenticated_header
      end

      assert_response :not_acceptable
    end
  end

  describe "processing a line item" do
    it "succeeds with invalid session_token" do
      post api_v1_drink_command_line_item_path( "123" ), params: line_item_params, headers: authenticated_header
      assert_response :created
    end

    it "succeeds" do
      post api_v1_drink_command_line_item_path( rfid ), params: line_item_params, headers: authenticated_header
      assert_response :created
    end

    it "succeeds with duplicate line item" do
      post api_v1_drink_command_line_item_path( rfid ), params: line_item_params, headers: authenticated_header
      assert_response :created

      post api_v1_drink_command_line_item_path( rfid ), params: line_item_params, headers: authenticated_header
      assert_response :created
    end

    it "succeeds with unknown session token" do
      post api_v1_drink_command_line_item_path( "xxxyyyttt" ), params: line_item_params, headers: authenticated_header
      assert_response :created
    end

    it "Raises error when empty params" do
      post api_v1_drink_command_line_item_path( "xxxyyyttt" ), params: {}, headers: authenticated_header

      assert_response 422
      parsed_response do |json|
        assert json.key?('data')
        assert_match %r{Missing Params}i, json.dig('data', 'errors', 'record').join
      end
    end

  end
end
