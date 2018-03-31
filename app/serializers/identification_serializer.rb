class IdentificationSerializer < ApplicationSerializer
  attr_reader :identification


  def initialize( identification, options ={} )
    @identification = identification

    super(options)
  end

  def data
    Hash(
      id: identification.id,
      identification_type: identification.identification_type,
      issuer: identification.issuer,
      expires_at: identification.expires_at.try(:iso8601),
      image_id: identification.image_id
    )
  end

end
