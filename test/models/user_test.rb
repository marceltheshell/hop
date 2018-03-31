require 'test_helper'

class UserTest < ActiveSupport::TestCase
  let(:user) { User.new(email: "test1@test.com", password: "123456") }
  let(:user_phone) { User.new(phone:"4153456050") }
  let(:active_users) {User.users_only.active}

  it "deactivates! user" do
    first_user = active_users.first
    assert  active_users.find_by(id: first_user[:id]).present?
    
    first_user.deactivate!
    refute  active_users.find_by(id: first_user[:id]).present?
    assert_equal (active_users.count + User.users_only.deleted.count), User.users_only.count
  end

  it "audit tracking of rfid field" do
    user.save!
    user.update!(rfid: SecureRandom.uuid)
    assert_equal 1, user.audits.count
  end

  it "can't assign RFID that is in users' history" do
    rfid = SecureRandom.uuid
    user.update!(rfid: rfid)      # original assignment
    user.update!(rfid: '123456')  # reassign to push into rfid history

    ex = assert_raises(ActiveRecord::RecordInvalid) {
      users(:one).update!(rfid: rfid)
    }

    assert_match %r{rfid previously taken}i, ex.message
  end

  it "returns qr_code_path for current RFID" do
    user = users(:two)

    assert user.rfid.present?
    assert_match %r{qrcodes/}i, user.qr_code_path
  end

  it "returns nil when there is no rfid for user" do
    user = User.create(email: "new_user_test@br.us")

    refute user.rfid.present?
    assert user.qr_code_path.nil?
  end

  it "can have empty password" do
    user.password = nil

    assert user.valid?
    assert user.errors.empty?
  end

  it "only one required field can be nil" do
    user_1 = User.new(email: nil, phone: "123456")
    user_2 = User.new(phone: nil, email: "br@br.us")

    assert user_1.valid?
    assert user_2.valid?
  end

  it "more than one users can have blank phone" do
    User.create!(email: "test1@test.com", phone: "")
    User.create!(email: "test2@test.com", phone: "")

    assert User.find_by(email: "test1@test.com")
    assert User.find_by(email: "test2@test.com")
  end

  it "more than one users can have blank email" do
    User.create!(email: "", phone: "5556667777")
    User.create!(email: "", phone: "8889991010")

    assert User.find_by(phone: "5556667777")
    assert User.find_by(phone: "8889991010")
  end

  it "raises exception when missing required fields" do
    ex = assert_raises(ActiveRecord::RecordInvalid) { user.update!(email: nil) }

    assert_match %r{email can't be blank}i, ex.message
    assert_match %r{Phone can't be blank}i, ex.message
  end

  it "validation raises exception instead of 'PG::UniqueViolation: ERROR' when both required fields are not unique" do
    user.save!
    user_phone.save!
    ex = assert_raises(ActiveRecord::RecordInvalid) {
      User.create!(phone: "4153456050", email: "test1@test.com")
    }

    assert_match %r{Phone has already been taken}i, ex.message
    assert_match %r{Email has already been taken}i, ex.message
  end

  it "raises exception when both required fields are set to nil" do
    u = User.create!(phone: "123456", email: "abcd@br.us")
    ex = assert_raises(ActiveRecord::RecordInvalid) {
      u.update!(email:nil, phone: nil)
    }

    assert_match %r{Phone can't be blank}i, ex.message
    assert_match %r{Email can't be blank}i, ex.message
  end

  it "can't have duplicate rfid's" do
    User.create!(email: "test1@test.com", password: "123456", rfid: "123456", phone:"4153456050")
    ex = assert_raises(ActiveRecord::RecordInvalid) {
      User.create!(email: "test2@test.com", password: "123456", rfid: "123456", phone:"3153456050")
    }

    assert_match %r{Rfid has already been taken}i, ex.message
  end

  it "can change password" do
    assert user.save!
    assert user.authenticate("123456")
    assert user.update!(password: "654321")
    assert user.authenticate("654321")
  end

  it "users' default role is 'user'" do
    assert user.valid?
    assert_equal "user", user.role
  end

  it "track rfid changes and QRCode add/remove enqueued jobs" do
    assert_equal 0, QrCodeJob.jobs.size
    assert_equal 0, RemoveQrCodeJob.jobs.size
    user.update!(rfid: "123456")
    assert_equal 1, QrCodeJob.jobs.size
    assert_equal 0, RemoveQrCodeJob.jobs.size
    assert user.rfid_history.empty?

    user.update!(rfid: "654321")
    assert_equal 2, QrCodeJob.jobs.size
    assert_equal 1, RemoveQrCodeJob.jobs.size
    refute user.rfid_history.empty?
    assert_includes user.rfid_history, "123456"
  end

  describe "User#search" do

    it "find user by RFID" do
      users = User.search( "abcd1234" )

      assert_equal 1, users.count
      assert_equal "abcd1234", users.first.rfid
    end

    it "find user by Email" do
      users = User.search( "55555@test.com" )

      assert_equal 1, users.count
      assert_equal "55555@test.com", users.first.email
    end

    it "find user by Phone" do
      users = User.search( "9543534443" )

      assert_equal 1, users.count
      assert_equal "9543534443", users.first.phone
    end

    it "find active only users" do
      users = User.active.search( "abcd1234" )

      assert users.count > 0
    end

    it "find deactive only users" do
      User.find_each(&:deactivate!)
      users = User.deleted.search( "abcd1234" )

      assert users.count > 0
    end

  end
end
