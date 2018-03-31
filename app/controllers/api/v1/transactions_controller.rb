class Api::V1::TransactionsController < Api::SecuredController
  before_action :find_user

  # GET /transactions
  def index
    @transactions = @user.user_transactions.order(created_at: :desc)
    @transactions = @transactions.by_type( params[:q] ) unless params[:q].blank?   # filters trans by type
    @transactions = @transactions.page( params[:page] ).per( params[:per_page] )   # pagination
    
    render json: ::Transaction::TransactionsSerializer.new( @transactions ), status: :ok
  end

  private

  def find_user
    @user ||= User.find_by(rfid: params[:user_id])
    @user ||= User.find_by(id: params[:user_id])
    raise ActiveRecord::RecordNotFound if @user.nil?
  end

end
