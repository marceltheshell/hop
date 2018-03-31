class DrinkCommand::CustomerSerializer < ApplicationSerializer
  attr_reader :user

  def initialize( user, options ={} )
    @user = user
    super(options)
  end

  def data
    Hash(
      first_name:             user.first_name,
      last_name:              user.last_name,
      name_on_card:           info.name_on_card,
      card_type:              info.card_type,
      masked_number:          info.masked_number,
      expires_at:             info.expires_at,
      balance_in_cents:       user.current_balance,
      credit_limit_in_cents:  credit_limit
    )
  end

  #
  #
  #
  private

  #
  # Global setting for credit limit. This would be used
  # by DrinkCommand to limit the per-pour dollar amount.
  #
  # Note: cannot exceed the users' current balance.
  #
  def credit_limit
    [
      Settings.credit_limit_in_cents.to_i,
      user.current_balance
    ].min
  end

  #
  # Users' payment method details
  #
  def info
    @info ||= user.payment_method || PaymentMethod.new
  end
end
