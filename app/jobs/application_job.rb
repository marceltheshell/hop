class ApplicationJob
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: 0

  # If job fails, try again in 1 min
  sidekiq_retry_in do |count|
    60 * (count + 1) # (i.e. 1, 2, 3, 4, 5)
  end

  #
  # Wrap AR operations so the connection
  # is returned to the pool.
  #
  def with_db_connection(&block)
    ActiveRecord::Base.connection_pool.with_connection(&block)
  end


  #
  # ClassMethods
  #
  class << self
    #
    # Alias method for backward compatibility with ActiveJob
    #
    def perform_later(*args)
      perform_async(*args)
    end

    #
    # Alias method for backward compatibility with ActiveJob
    #
    def perform_now(*args)
      new.perform(*args)
    end
  end
end
