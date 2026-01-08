class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending processing paid completed cancelled failed] }
  validates :shipping_name, :shipping_address, :shipping_city, :shipping_zip, :shipping_country, :email, presence: true

  before_create :generate_order_number

  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }

  def pending?
    status == 'pending'
  end

  def paid?
    status == 'paid'
  end

  def completed?
    status == 'completed'
  end

  def cancelled?
    status == 'cancelled'
  end

  def full_address
    "#{shipping_address}, #{shipping_city}, #{shipping_state} #{shipping_zip}, #{shipping_country}"
  end

  private

  def generate_order_number
    self.order_number = "ORD-#{Time.now.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end
end
