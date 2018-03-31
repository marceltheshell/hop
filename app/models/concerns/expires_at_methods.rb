module ExpiresAtMethods
  extend ActiveSupport::Concern

  included do
    # intentionally blank
  end

  #
  # Overwrite the setter, convert to
  # Date object on assignment.
  #
  def expires_at=(val)
    super( parse_date(val) )
  rescue ArgumentError
    super (val)
  end

  #
  # Overwrite the reader, force to Date object.
  #
  # Returns 'nil' if date parsing fails.
  #
  def expires_at
    parse_date( super )
  rescue ArgumentError
    nil
  end

  #
  # is expired?
  #
  def expired?
    expires_at.nil? || expires_at.past?
  end

  #
  #
  #
  private

  #
  # Parse date if its not a 'Date' object.
  #
  def parse_date( day )
    day.is_a?(Date) ? day : Date.parse( day.to_s )
  end
end
