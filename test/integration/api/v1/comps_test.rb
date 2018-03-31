require 'test_helper'

class Api::V1::CompsTest < ActionDispatch::IntegrationTest
  let(:user) { users(:two) }
  let(:payment_method) { payment_methods(:default) }
  let(:comp_params) { Hash(amount_in_cents: 500) }

  it 'comps#create success' do
    previous_balance = user.current_balance

    post api_v1_comps_path(user.id), params: Hash(comp: comp_params), headers: authenticated_header

      assert_response :created
      assert_equal (previous_balance+comp_params[:amount_in_cents]), user.current_balance

      parsed_response do |json|
        assert json.key?('data')
        assert json.dig('data', 'comp').key?('id')
        assert json.dig('data', 'comp').key?('employee_id')
        assert json.dig('data', 'comp').key?('venue_id')
      end
  end

  it 'comps#create processes comp amount_in_cents < 0 as a positive' do
    previous_balance = user.current_balance

    post api_v1_comps_path(user.id), params: Hash(comp: {amount_in_cents: -500}), headers: authenticated_header
    assert_response :success
    assert_equal previous_balance + 500 , user.current_balance

  end


  it 'renders error when user is missing' do

    post api_v1_comps_path('123'), params: Hash(comp: comp_params), headers: authenticated_header

    assert_response :not_found
    parsed_response do |json|
      assert json.key?('data')
      assert json.dig('data').key?('errors')
      assert json.dig('data', 'errors').key?('record')
      assert_match %r{Record not found}i, json.dig('data', 'message')
    end
  end
end
