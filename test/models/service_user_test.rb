require 'test_helper'

class ServiceUserTest < ActiveSupport::TestCase
  let(:service) { ServiceUser.new(email: "employee-app@test.com", password: "123456") }
  let(:service_pin) { ServiceUser.new(email: "employee-app_pin@test.com", pin: "123456") }

  it "can't have empty email" do
    ex = assert_raises(ActiveRecord::RecordInvalid) { service.update!(email: nil) }
    assert_match %r{email can't be blank}i, ex.message
  end

  it "is a service account" do
    service.save!
    assert_equal "ServiceUser", User.last.type
    assert User.last.is_a?(ServiceUser)
  end

  it "service users' default role is 'service'" do
    assert service.valid?
    assert_equal "service", service.role
  end

  it "has valid service_token" do
    service.save!
    auth_token = service.to_service_token
    refute auth_token.token.blank?
    assert ServiceToken.new(token: auth_token.token).entity_for(ServiceUser)
    assert Knock::AuthToken.new(token: auth_token.token).entity_for(ServiceUser)
  end

  it "Service User can be found using PIN" do
    service_pin.save!
    service_user = ServiceUser.find_by(pin: service_pin.pin)

    assert_equal service_pin.email, service_user.email
    assert_equal service_pin.pin, service_user.pin
    assert_equal "ServiceUser", service_user.type
  end

  it "Raises exception when PIN is not 6 digits long" do
    user = ServiceUser.new(email: "employee-app1@test.com", pin: "12345")
    ex = assert_raises(ActiveRecord::RecordInvalid) {user.save!}
      assert_match %r{Pin PIN must be 6 digits long}i, ex.message
  end

  it "Raises exception when PIN is not unique" do
    service_pin.save!
    user = ServiceUser.new(email: "employee-app1@test.com", pin: "123456")
    ex = assert_raises(ActiveRecord::RecordInvalid) {user.save!}
      assert_match %r{Pin has already been taken}i, ex.message
  end

  it "Service User can have empty phone field" do
    service_user = ServiceUser.new(email: "employee-app1@test.com", pin: "123456")
    service_user.save!
    assert service_user.valid?
  end

end
