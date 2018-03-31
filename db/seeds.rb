# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create!(email: "david.bradford@bluerocket.us", password: "123456")
User.create!(email: "humberto@bluerocket.us", password: "123456")

#
# Create service users -- used for mobile app without user context
#
ServiceUser.create!(
  email: "hop-employee-app-staging@bluerocket.us",
  password: "cf1099b50ccfcd37e8ca693deebaa2f7" )

ServiceUser.create!(
  email: "drink-command-app@bluerocket.us",
  password: "3a94d8ae789d1c2abf52331cae253d72" )

#
# Create some test accounts for Drink Command integration.
#
User.transaction do
  #
  # Complete user w/balance
  #
  user = UserComposite.new(
    email: "drink-command-test+1@bluerocket.us",
    password: "123456",
    rfid: "1685583841",
    first_name: "Test",
    last_name: "User-1",
    phone: "555-555-5555",
    payment_method: {
      token: '1000000074340019',
      expires_at: '2018-06-01',
      card_type: 'visa',
      masked_number: '***************1234',
      name_on_card: 'Test User-1'
    }
  ).create!

  user.comps.create!(
    amount_in_cents: 1500, description: 'New account promo')

  #
  # User w/balance & expired card
  #
  user = UserComposite.new(
    email: "drink-command-test+2@bluerocket.us",
    password: "123456",
    rfid: "1685583842",
    first_name: "Test",
    last_name: "User-2",
    phone: "555-555-5556",
    payment_method: {
      token: '3d0fa96b41499178c4d6b63aabb64195',
      expires_at: '2016-06-01',
      card_type: 'visa',
      masked_number: '***************1235',
      name_on_card: 'Test User-2'
    }
  ).create!

  user.comps.create!(
    amount_in_cents: 500, description: 'New account promo')

  #
  # User w/missing payment & no balance
  #
  user = UserComposite.new(
    email: "drink-command-test+3@bluerocket.us",
    password: "123456",
    rfid: "1685583843",
    first_name: "Test",
    last_name: "User-3",
    phone: "555-555-5557"
  ).create!
end

#
# Create initial venues.
#
Venue.transaction do
  Venue.create!(
    name: 'Harmon Corner',
    street1: "3717 Las Vegas Blvd South",
    city: "Las Vegas",
    state: "NV",
    country: "US",
    postal: "89109"    
  ).tap do |venue|
    venue.cameras.create!(
      style: :podium,
      url: 'rtsp://admin:123456@192.168.88.94:7070/stream1',
      name: "Podium #1"
    )
    venue.cameras.create!(
      style: :podium,
      url: 'http://admin:123456@10.0.1.58:8081',
      name: "Podium #2"
    )
  end

  Venue.create!(
    name: 'Las Vegas North Premium Outlets',
    street1: "875 S Grand Central Pkwy",
    city: "Las Vegas",
    state: "NV",
    country: "US",
    postal: "89106"    
  ).tap do |venue|
    venue.cameras.create!(
      style: :podium,
      url: 'rtsp://admin:123456@192.168.88.94:7070/stream1',
      name: "Podium #1"
    )
    venue.cameras.create!(
      style: :podium,
      url: 'http://admin:123456@10.0.1.58:8081',
      name: "Podium #2"
    )
  end

  Venue.create!(
    name: 'Las Vegas South Premium Outlets',
    street1: "7400 Las Vegas Blvd S",
    city: "Las Vegas",
    state: "NV",
    country: "US",
    postal: "89123"    
  ).tap do |venue|
    venue.cameras.create!(
      style: :podium,
      url: 'rtsp://admin:123456@192.168.88.94:7070/stream1',
      name: "Podium #1"
    )
    venue.cameras.create!(
      style: :podium,
      url: 'http://admin:123456@10.0.1.58:8081',
      name: "Podium #2"
    )
  end

  Venue.create!(
    name: 'Sansome',
    street1: "233 Sansome St., Suite 1100",
    city: "San Francisco",
    state: "CA",
    country: "US",
    postal: "94104"    
  ).tap do |venue|
    venue.cameras.create!(
      style: :podium,
      url: 'rtsp://admin:123456@192.168.88.94:7070/stream1',
      name: "Podium #1"
    )
    venue.cameras.create!(
      style: :podium,
      url: 'rtsp://admin:123456@192.168.88.78:7070/stream1',
      name: "Podium #2"
    )
  end
end
