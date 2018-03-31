class UserNotifierMailer < ApplicationMailer
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  layout false
  #
  #
  #
  def welcome_email( user_id )
    @user = User.find( user_id )
    ensure_email_address!(@user)
    mail(to: @user.email,
      subject: I18n.t( 'email.welcome' ),
      template_path: 'user_notifier_mailer',
      template_name: 'Hop_Transactional_Welcome')
  end

  #
  #
  #
  def charge_email( trans_id )
    @charge = Transaction::Charge.find( trans_id )
    @user   = @charge.user

    ensure_email_address!(@user)
    mail(to: @user.email,
      subject:  I18n.t( 'email.charge' ),
      template_path: 'user_notifier_mailer',
      template_name: 'Hop_Transactional_Receipt')
  end
  #
  #
  #
  private

  def ensure_email_address!(user)
    raise ActiveRecord::RecordNotFound, "email is blank" if user.email.blank?
  end

  def not_found(ex)
    logger.warn("Email delivery skipped, #{ex.message}.")
  end
end
