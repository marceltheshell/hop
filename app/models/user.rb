class User < ApplicationRecord
  include UploadedImage

  # audit trail
  audited except: [:password_digest], on: [:update, :destroy]

  # skip requiring password at create
  has_secure_password validations: false

  #
  # kaminari default items per page
  #
  paginates_per 100

  #
  # Validations
  #
  validates :email, presence: true, unless: ->(u) { u.phone.present? }
  validates :phone, presence: true, unless: ->(u) { u.email.present? }
  validates :email, uniqueness: true, allow_blank: true
  validates :phone, uniqueness: true, allow_blank: true
  validates :rfid, uniqueness: true, allow_nil: true
  validate do
    if rfid.present? && ::User.rfid_history_contains(rfid).exists?
      errors.add(:rfid, "previously taken")
    end
  end


  #
  # Associations
  #
  has_many :line_items
  has_many :addresses, validate: true, autosave: true
  has_one :identification, validate: true, autosave: true
  has_one :payment_method, validate: true, autosave: true

  # Transaction associations
  has_many :user_transactions
  has_many :purchases,  class_name: 'Transaction::Purchase'
  has_many :charges,    class_name: 'Transaction::Charge'
  has_many :refunds,    class_name: 'Transaction::Refund'
  has_many :comps,      class_name: 'Transaction::Comp'
  has_many :credits,    class_name: 'Transaction::Credit'

  #
  # scopes
  #
  scope :users_only,            -> { where(type: nil) }
  scope :active,                -> { where(deactivated_at: nil) }
  scope :deleted,               -> { where.not(deactivated_at: nil) }
  scope :rfid_history_contains, -> (rfid) { where("? = ANY(rfid_history)", rfid) }

  #
  # Callbacks
  #
  before_validation :setup_role
  before_save :track_rfids
  after_save :generate_barcode
  after_destroy :remove_qrcode

  #
  # instance methods
  #
  def deactivate!
    update!(deactivated_at: Time.now.utc)
  end

  def current_balance
    #need update balance_in_cents for those records without one
    user_transactions.order(created_at: :desc).first.try(:balance_in_cents).to_i
  end

  def calculated_balance
    user_transactions.sum(:amount_in_cents).to_i
  end

  def service?
    role.to_s.downcase == 'service'
  end

  def qr_code_path
    StorageService::QRCODE_PATH % qr_code_name if qr_code_name
  end

  def qr_code_name
    [id, rfid].join("_") if rfid.present?
  end

  def old_qrcode_name
    [id, rfid_was].join("_")
  end

  private

  #
  # Queue job to generate a QR/barcode for RFID value.
  #
  def generate_barcode
    if has_rfid_changed?
      QrCodeJob.perform_later( self.id )
      RemoveQrCodeJob.perform_later( old_qrcode_name ) if rfid_was.present?
    end
  end

  def remove_qrcode
     RemoveQrCodeJob.perform_later( qr_code_name ) if rfid.present?
  end

  #
  # Default role to 'user'
  #
  def setup_role
    self.role ||= 'user'
  end

  #
  # Track RFID changes; appends previous value
  # to 'rfid_history' array.
  #
  def track_rfids
    if rfid_changed? && rfid_was.present?
      self.rfid_history ||= []
      self.rfid_history.push( rfid_was ) unless rfid_history.include?( rfid_was )
    end
  end

  #
  # Checks after_save RFID value
  # before calling QrCodeJob
  #
  def has_rfid_changed?
    self.changed_attributes.key?('rfid') && (self.rfid != self.rfid_was)
  end

  #
  # ClassMethods
  #
  class << self
    #
    # Search for user :
    #   - RFID
    #   - Email
    #   - Phone
    #
    def search( term )
      where("rfid=? OR email=? OR phone=?", term, term, term)
    end

  end
end
