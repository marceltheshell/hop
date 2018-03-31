class Api::V1::UsersController < Api::SecuredController
  before_action :set_user, only: [:show, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.users_only.active                                              # only active users
    @users = @users.search( params[:q] ) unless params[:q].blank?     # search for term
    @users = @users.page( params[:page] ).per( params[:per_page] )    # paginate

    render json: UsersListSerializer.new(@users), status: :ok
  end

  # GET /users/1
  # GET /users/1.json
  def show
    render json: UserSerializer.new( @user ), status: :ok
  end

  # POST /users
  # POST /users.json
  def create
    user = UserComposite.new( user_params ).create!
    render json: UserSerializer.new( user ), status: :created
  rescue ActiveRecord::RecordInvalid => ex
    render json: UserSerializer.new( ex.record ), status: :unprocessable_entity
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    UserComposite.new( user_params.merge(id: params[:id]) ).update!
    render json: StatusSerializer.new(:accepted), status: :accepted
  rescue ActiveRecord::RecordInvalid => ex
    render json: UserSerializer.new( ex.record ), status: :unprocessable_entity
  end

  # DELETE /users/1
  # DELETE /users/1?force=true
  # DELETE /users/1.json
  def destroy
    forced? ? @user.destroy! : @user.deactivate!
    render json: StatusSerializer.new(:deleted), status: :ok
  end

  private

  #
  # Use callbacks to share common setup or
  # constraints between actions.
  #
  def set_user
    @user ||= User.find_by(rfid: params[:id])
    @user ||= User.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound if @user.nil?
  end

  def forced?
    params[:force] == 'true'
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(
      :id, :first_name, :middle_name,
      :last_name, :height_in_cm, :weight_in_kg, :gender, :dob, :phone,
      :email, :password, :rfid, :image_id,
      addresses: [
        :id, :street1, :street2, :city, :state, :country, :postal, :address_type ],
      identification: [
        :id, :identification_type, :issuer, :expires_at, :image_id ],
      payment_method: [
        :id, :card_type, :token, :expires_at, :name_on_card, :masked_number ]
    ).to_h
  end

end
