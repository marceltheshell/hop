class UsersListSerializer < ApplicationSerializer
  include Rails.application.routes.url_helpers
  attr_reader :users

  def initialize( users, options ={} )
    @users = users
    @per_page = users.limit_value || 100
    @next_page = api_v1_users_path(page: users.next_page, per_page: @per_page) #"/users?page=#{users.next_page}&per_page=#{@per_page}"
    @page_total = users.total_pages
    @total = users.total_count
    super(options)
  end

  def data
    Hash(
      total: @total,
      pages: @page_total,
      next_page: (users.next_page ? @next_page : nil)
    ).compact.merge(user_list_builder)
  end

  def user_list_builder
    serializers = users.map do |user|
      UserSerializer.new(user, {collection: true, nested: false} ).as_json
    end
    Hash(users: serializers)
  end

end
