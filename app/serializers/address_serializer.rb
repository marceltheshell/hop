class AddressSerializer < ApplicationSerializer
  attr_reader :address


  def initialize( address, options ={} )
    @address = address

    super(options)
  end

  def data
    Hash(
      id: address.id,
      address_type: address.address_type,
      street1: address.street1,
      street2: address.street2,
      city: address.city,
      state: address.state,
      country: address.country,
      postal: address.postal
    )
  end

end
