# in app/middleware/catch_json_parse_errors.rb
class CatchJsonParseErrors
  def initialize(app)
    @app  = app
    @code = 10012
    @msg = "Invalid Format"
    @error_output = Hash(request: ["Invalid JSON Format"])
  end

  def call(env)
    begin
      @app.call(env)
    rescue ActionDispatch::ParamsParser::ParseError => error
      content_type_json?(env) ? parse_error_response : raise(error)
    end
  end

  private

  def content_type_json?(env)
    env['CONTENT_TYPE'] =~ /application\/json/
  end

  def parse_error_response
    return [
      422, { "Content-Type" => "application/json" },
      [ { code: @code, message: @msg, errors: @error_output }.to_json ]
    ]
  end

end
