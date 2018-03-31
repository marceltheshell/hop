module SeedDbHelper

  def seed_loader
    create_fake_users
    user_charge
    user_purchases
  end

  def create_fake_users(num = 5)
    num.to_i.times do
      user = User.create!(
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        email: Faker::Internet.unique.email,
        password: Faker::Internet.password
      )
    end
  end

  def create_user_charge(user=User.first, amount=12000)
    user.charges.create!(
      description: 'Adds $ to RFID Card',
      amount_in_cents: deposit
    )
  end

  def user_purchases(user=User.first, num=10)
    num.to_i.times do
      amt = -850
      user.purchases.create!(
        description: 'Lagunitas',
        amount_in_cents: amt
      )
    end
  end

end
