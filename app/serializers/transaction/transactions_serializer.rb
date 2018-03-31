class Transaction::TransactionsSerializer < ApplicationSerializer
  include Rails.application.routes.url_helpers
  attr_reader :transactions

  def initialize( transactions, options={} )
    @transactions = transactions
    @user_id = transactions.pluck(:user_id).first
    @per_page = transactions.limit_value || 100
    @next_page = api_v1_transactions_path(user_id: @user_id, page: transactions.next_page, per_page: @per_page ) #"/transactions?page=#{transactions.page.next_page}"
    @page_total = transactions.total_pages
    @total = transactions.total_count
    super(options)
  end

  def data
    Hash(
      total: @total,
      pages: @page_total,
      next_page: (transactions.next_page ? @next_page : nil)
    ).compact.merge(transactions_builder)
  end

  def transactions_builder
    serialized = transactions.map do |t|
       transaction_serializer(t)
    end

    Hash(transactions: serialized )
  end

  def transaction_serializer(transaction)
    Hash(
      id: transaction.id ,
      type: transaction.type,
      amount_in_cents: transaction.amount_in_cents,
      balance_in_cents: transaction.balance_in_cents,
      description: transaction.description,
      tap_id: transaction.tap_id,
      qty: transaction.qty,
      venue_id: transaction.venue_id,
      created_at: transaction.created_at
    )
  end
end
