class UserSerializer < ApplicationSerializer
  attr_reader :user, :car_id

  def initialize( user, options ={} )
    @user = user
    super(options)
  end

  def data
    data = Hash(
      id: user.id,
      type: user.type,
      role: user.role,
      first_name: user.first_name,
      last_name: user.last_name,
      middle_name: user.middle_name,
      height_in_cm: user.height_in_cm,
      weight_in_kg: user.weight_in_kg,
      gender: user.gender,
      dob: user.dob,
      phone: user.phone,
      email: user.email,
      image_id: user.image_id,
      rfid: user.rfid,
      qr_code_path: user.qr_code_path,
      balance_in_cents: user.current_balance,
      deactivated_at: user.deactivated_at.try(:iso8601)
    ).merge(combined_serializers)

    data = Hash(user: data) if nested? #skips userlist and auth responses

    data
  end

  def errors?
    return false if collection?
    user.errors.any?
  end

  def errors
    ErrorSerializer.new(
      code: 10003,
      errors: combined_errors
    ).as_json
  end

  private

  #Errors

  def combined_errors
    user_errors
    .merge( address_errors )
    .merge( identification_errors )
    .merge( payment_method_errors )
    .compact
  end

  def payment_method_errors
    return {} unless association_errors?(:payment_method)
    Hash(payment_method: user.payment_method.errors.as_json)
  end

  def identification_errors
    return {} unless association_errors?(:identification)
    Hash(identification: user.identification.errors.as_json)
  end

  def address_errors
    list = [*user.addresses].map do |a|
      if a.errors.empty?
        {}
      else
        Hash("#{a.address_type}_address" => a.errors.as_json)
      end
    end
    list.reduce({}, :merge)
  end

  def user_errors
    user.errors.as_json
    .delete_if{|k,v| k =~ /addresses|identification|payment_method/} # drop association errors
  end

  # serializers

  def combined_serializers
    Hash(
      addresses: addresses_serializer,
      identification: identification_serializer,
      payment_method: payment_method_serializer
    )
  end

  def addresses_serializer
    [*user.addresses].map do |a|
      AddressSerializer.new(a).as_json
    end
  end

  def identification_serializer
    return {} unless user.identification
    IdentificationSerializer.new(user.identification).as_json
  end

  def payment_method_serializer
    return {} unless user.payment_method
    PaymentMethodSerializer.new(user.payment_method).as_json
  end

  def association_errors?(item)
    user.association(item).target.present? &&
    user.association(item).target.errors.present?
  end

  #helpers

  def collection?
    @collection == true
  end

  def nested?
    @nested == true
  end

end
