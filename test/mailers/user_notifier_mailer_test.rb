require 'test_helper'

class UserNotifierMailerTest < ActionMailer::TestCase
  let(:user) { users(:one) }
  let(:from) { "noreply@adultbev.co" }

  it "welcome email" do
    user.update!(first_name: "Tester")
    email = UserNotifierMailer.welcome_email(user.id)

    assert_emails 1 do
      email.deliver_now
    end

    body = email.html_part.body.decoded
    assert_equal [ from ], email.from
    assert_equal [ user.email ], email.to
    assert_equal 'Welcome to Hop', email.subject
    assert_match %r{<!DOCTYPE HTML PUBLIC}i, body
  end

  it "charge email" do
    trans = Transaction::Charge.create!(user: user, amount_in_cents: 500)
    email = UserNotifierMailer.charge_email(trans.id)

    assert_emails 1 do
      email.deliver_now
    end

    body = email.html_part.body.decoded
    assert_equal [ from ], email.from
    assert_equal [ user.email ], email.to
    assert_equal 'Your Hop Account Balance Has Changed', email.subject
    assert_match %r{<!DOCTYPE HTML PUBLIC}i, body
  end

  it " will not send email without an email address" do
    user.update!(phone: "1112223333", email: nil)
    assert_emails 0 do
      UserNotifierMailer.welcome_email(user.id).deliver_now
    end
  end
end
