require 'csv'

class ReportsController < ApplicationController

  def users
    send_data users_as_csv, filename: "users-#{Date.today.iso8601}.csv"
  end

  #
  #
  #
  private

  def users_as_csv
    CSV.generate(headers: true) do |csv|
      csv << %w{id type email phone 
        first_name last_name dob rfid pin 
        balance card_type masked_number
        expires_at name_on_card image_url
        identification_url, qr_code_url}

      User.includes(
        :payment_method, :identification).find_each do |user|
        payment  = user.payment_method || PaymentMethod.new
        identity = user.identification || Identification.new

        csv << [
          user.id,
          user.type,
          user.email,
          user.phone,
          user.first_name,
          user.last_name,
          user.dob,
          user.rfid,
          user.pin,
          user.current_balance,
          payment.card_type,
          payment.masked_number,
          payment.expires_at,
          payment.name_on_card,
          StorageService.signed_lowres_url( user.image_id, 1.week),
          StorageService.signed_lowres_url( identity.image_id, 1.week),
          StorageService.signed_qrcode_url( user.qr_code_name, 1.week)
        ]
      end
    end    
  end
end
