class StatusSerializer
  attr_reader :status

  def initialize( status)
    @status = status
  end

  def as_json
    Hash( data: Hash(status: status) )
  end

  def to_json(*args, &block)
    JSON.dump( as_json ).tap do |json|
      yield( json ) if block_given?
    end
  end

end
