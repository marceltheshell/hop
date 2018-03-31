class ApplicationSerializer
  attr_reader :collection, :nested
  attr_accessor :root_node, :data_node
  
  def initialize( options = {} )
    options.to_options!

    @root_node    ||= options.fetch(:root_node, 'data')
    @data_node    ||= options.fetch(:data_node, nil)

    # FIXME: phase these out
    @collection   ||= options.fetch(:collection, false)
    @nested       ||= options.fetch(:nested, true)

    after_initialize
  end

  def after_initialize
    # Intentionally Blank
  end

  def data
    raise NotImplementedError
  end

  def errors
    raise NotImplementedError
  end

  def errors?
    false
  end

  def as_json(&block)
    data_or_errors.tap do |json|
      yield( json ) if block_given?
    end
  end

  def to_json(*args, &block)
    JSON.dump( root_wrapper( as_json ) ).tap do |json|
      yield( json ) if block_given?
    end
  end


  private

  def with_root_node?
    root_node.present? && root_node != false
  end

  def with_data_node?
    data_node.present? && data_node != false
  end

  def data_or_errors
    ( errors? ? errors : data_wrapper(data) ).deep_stringify_keys
  end

  def data_wrapper( object )
    with_data_node? ? Hash(data_node => object ) : object
  end

  def root_wrapper( object )
    with_root_node? ? Hash(root_node => object ) : object
  end
end
