class UserComposite
  attr_reader :user_id, :user_data, :addresses, :identity, :payment_method

  def initialize( user_data )
    @user_data      = user_data

    @user_id        = @user_data.delete(:id)
    @addresses      = Array(@user_data.delete(:addresses) || [])
    @identity       = @user_data.delete(:identification)  || {}
    @payment_method = @user_data.delete(:payment_method)  || {}
   end

  #
  # Update the user w/associations. Raises exception
  # on validation errors.
  #
  def update!
    User.transaction do
      user = User.find( user_id )
      user.assign_attributes( user_data )

      # addresses
      addresses.each do |a|
        next if a.empty?
        id = a.delete(:id)
        address = user.addresses.find_by( id: id )                # try to find
        address = user.addresses.first_or_initialize if address.nil?  # or first address
        address.assign_attributes( a )                                # update address data

        user.addresses << address                                     # add to user again to be saved
      end

      # identification
      if identity.present?
        id = identity.delete(:id)
        obj = user.identification || user.build_identification
        obj.assign_attributes( identity )
      end

      # payment method
      if payment_method.present?
        id = payment_method.delete(:id)
        obj = user.payment_method || user.build_payment_method
        obj.assign_attributes( payment_method )
      end

      user.save!
    end
  end

  #
  # Create the user w/associations. Raises exception
  # on validation errors.
  #
  def create!
     User.transaction do
       user = User.new( user_data )

      # addresses
      addresses.each do |a|
        user.addresses << Address.new( a ) unless a.empty?
      end

      # identification
      user.identification = Identification.new(
        identity ) unless identity.empty?

      # payment method
      user.payment_method = PaymentMethod.new(
        payment_method ) unless payment_method.empty?

      user.save!
      send_welcome_email(user)

      user
    end
  end

  private

  def send_welcome_email(user)
    UserNotifierMailer.delay.welcome_email(user.id)
  end

end
