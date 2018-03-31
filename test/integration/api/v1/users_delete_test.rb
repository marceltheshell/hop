require 'test_helper'

class Api::V1::UsersDeleteTest < ActionDispatch::IntegrationTest
  let(:user) { users(:two) }

  it "users#destroy (deactivated)" do
    del_user = user

    delete api_v1_user_path(del_user.id), headers: authenticated_header
      assert_response :success
      assert_equal parsed_response.dig('data','status'), "deleted"
      assert_equal User.deleted.first[:id], del_user[:id]

      parsed_response do |json|
        assert json.dig('data').key?('status')
      end
  end

  it "users#destroy w/ flag :force=>true  (permanently)" do
    user[:rfid] = "abcd"
    user.save
    user[:rfid] = "efgh"
    user.save
    user[:rfid] = "ijkl"
    user.save
    del_user = user

    delete api_v1_user_path(del_user.id), params:{ force: true }, headers: authenticated_header
    assert_response :success
    assert_equal 3, QrCodeJob.jobs.size
    assert_equal 4, RemoveQrCodeJob.jobs.size
    assert_equal parsed_response.dig('data','status'), "deleted"

    ex = assert_raises(ActiveRecord::RecordNotFound) do
      User.find(del_user.id)
    end

    assert_match %r{Couldn't find User with 'id'}i, ex.message
  end

  it "users#destroy w/ flag :force=>nil or false (deactivated) " do
    del_user = user

    delete api_v1_user_path(del_user.id), params:{ force: nil }, headers: authenticated_header
      assert_response :success
      assert_equal 0, QrCodeJob.jobs.size
      assert_equal 0, RemoveQrCodeJob.jobs.size
      assert_equal parsed_response.dig('data','status'), "deleted"
      assert_equal User.deleted.first[:id], del_user[:id]
  end

  it "#Error record not found" do
    del_user = Hash(id: 12345)

    delete api_v1_user_path(del_user[:id]), headers: authenticated_header
    assert_response :not_found

    parsed_response do |json|
      assert json.dig('data').key?('code')
      assert json.dig('data').key?('message')
      assert json.dig('data').key?('errors')
      assert json.dig('data', 'errors').is_a?(Hash)
    end
  end

end
