class UserNotifierMailerPreview < ActionMailer::Preview
  def welcome
    binding.pry
    UserNotifierMailer.welcome_email( User.second.id )
  end

  def charge
    UserNotifierMailer.charge_email( Transaction::Charge.last.id )
  end
end
