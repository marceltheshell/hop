module JsonHelper
  #
  # Parse response body
  #
  def parsed_response(&block)
    JSON.parse( response.body ).tap do |json|
      yield json if block_given?
    end
  end
end
