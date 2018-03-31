class BootSerializer < ApplicationSerializer
  include Rails.application.routes.url_helpers

  attr_reader :auth_token

  def initialize( auth_token, options={} )
    @auth_token = auth_token
    super( options )
  end

  def data
    Hash(
      jwt: auth_token.token,
      resources: resource_routes,
      bridge_pay: bridgepay_config,
      aws: aws_config,
      venues: venues_as_json
    )
  end

  private

  #
  # Serialize all Venues w/camera for app.
  #
  def venues_as_json
    ::Venue.includes(:cameras).map do |v|
      Hash(
        id: v.id,
        drinkcommand_id: v.drinkcommand_id,
        name: v.name,
        cameras: cameras_as_json( v )
      )
    end
  end

  #
  # Serialize the cameras 
  #
  def cameras_as_json( venue )
    venue.cameras.map do |c|
      c.as_json(except: [:id, :venue_id, :created_at, :updated_at])
    end    
  end

  #
  # Pass Bridge Pay config to mobile client
  #
  def bridgepay_config
    Hash(
      username:         ::BridgePay.username,
      password:         ::BridgePay.password,
      merchant_code:    ::BridgePay.code,
      merchant_account: ::BridgePay.account
    )    
  end

  #
  # Pass AWS config to mobile client
  #
  def aws_config
    Hash(
      region:           AwsSettings.instance.region,
      bucket:           AwsSettings.instance.bucket,
      identity_id:      AwsSettings.instance.identity_id,
      identity_pool_id: AwsSettings.instance.identity_pool_id,
    ).merge( StorageService.paths )
  end

  #
  # Render resource routes for iOS & Android app
  #
  def resource_routes
    Hash(
      self:       api_v1_boot_path,
      auth:       api_v1_auth_path,
      users:      api_v1_users_path,
      charges:    api_v1_charges_path(':user_id'),
      purchases:  api_v1_purchases_path(':user_id'),
      credits:    api_v1_credits_path(':user_id'),
      comps:      api_v1_comps_path(':user_id')
    )
  end
end
