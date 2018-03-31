class Transaction::Purchase < Transaction::Withdrawal
  has_one :line_item
end
