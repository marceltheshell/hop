class DrinkCommand::ChargeSerializer < Transaction::ChargeSerializer

  def after_initialize
    self.data_node = false
  end

  def data
    Hash(
      amount_in_cents:  charge.amount_in_cents,
      balance_in_cents: charge.balance_in_cents,
      reference_number: ref_num
    )
  end

  def errors
    ErrorSerializer.new(
      code: 20400,
      errors: charge.errors.as_json
    ).as_json
  end

  private

  def ref_num
    charge.reference_number || charge.auth_code
  end
end
