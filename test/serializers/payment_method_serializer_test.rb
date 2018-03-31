require 'test_helper'

class PaymentMethodSerializerTest < ActiveSupport::TestCase
  let(:user) { users(:two) }
  let(:payment_method) { payment_methods(:default) }

  it "#as_json" do
    PaymentMethodSerializer.new( payment_method ).as_json do |json|
      assert json.key?('id')
      assert json.key?('card_type')
      assert json.key?('masked_number')
      assert json.key?('expires_at')
      refute json.key?('code')
      refute json.key?('message')
      refute json.key?('errors')
    end
  end

  it "serializes payment_method errors" do
    pmt_params  = Hash(card_type: 'visa', expires_at: '2017-01-01',
      name_on_card: 'Tess T Tesla')
    user_params = Hash(email: '55556@test.com',
      password: "12345", first_name: 'Tess', last_name:'Tesla')

    new_user = User.new(user_params)
    new_user.build_payment_method(pmt_params)

    refute new_user.valid?
    UserSerializer.new( new_user ).as_json  do |json|

      assert json.key?('code')
      assert json.key?('message')
      assert json.key?('errors')
      assert_match %r{can't be blank}i, json.dig('errors', 'payment_method', 'token').join
    end
  end

end
