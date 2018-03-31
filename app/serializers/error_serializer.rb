class ErrorSerializer
  attr_reader :code, :errors

  def initialize( options ={} )
    options.to_options!
    @code   = options.fetch(:code, 10001)
    @errors = options.fetch(:errors, Hash(default: ["details missing"]))
  end

  def as_json
    Hash(
      'code'    => code,
      'message' => message,
      'errors'  => errors,
    )
  end

  def to_json(*args, &block)
    JSON.dump( root_wrapper( as_json ) ).tap do |json|
      yield( json ) if block_given?
    end
  end

  def message
    I18n.t("api.errors.#{code}")
  end


  private

  def root_wrapper( data )
    Hash('data' => data )
  end
end
