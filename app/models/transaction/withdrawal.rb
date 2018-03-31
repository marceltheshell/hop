class Transaction::Withdrawal < UserTransaction
  before_validation :withdrawal_amount, prepend: true

  private

  def withdrawal_amount
    self.amount_in_cents = -(self.amount_in_cents.to_i.abs)
  end
end
