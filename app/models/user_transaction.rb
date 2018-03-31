class UserTransaction < ApplicationRecord
  belongs_to :user, required: true

  after_initialize do
    self.metadata ||= {}
  end

  #
  # kaminari default items per page
  #
  paginates_per 100

  before_validation :calculate_new_balance
  validates :balance_in_cents, allow_blank: nil, :numericality => {:greater_than_or_equal_to => 0}

  private

  def calculate_new_balance
    self.user ||= User.find(user_id) # only lookup user if its not assigned already
    self.balance_in_cents = (user.current_balance + amount_in_cents.to_i)
  end

  class << self
    #
    # filter by type
    #
    def by_type( type )
      case type.to_s.downcase
      when 'refund'
        where(type: 'Transaction::Refund')
      when 'credit'
        where(type: 'Transaction::Credit')
      when 'purchase'
        where(type: 'Transaction::Purchase')
      when 'charge'
        where(type: 'Transaction::Charge')
      when 'comp'
        where(type: 'Transaction::Comp')
      else
        all
      end
    end

  end
end
