class Transaction::Deposit < UserTransaction
  before_validation :deposit_amount, prepend: true

  private

  def deposit_amount
    self.amount_in_cents = self.amount_in_cents.to_i.abs
  end



end
