class User < ApplicationRecord
  has_secure_password
  
  has_many :carts, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :wishlist_items, dependent: :destroy
  has_many :wishlisted_variants, through: :wishlist_items, source: :product_variant
  
  validates :email, presence: true, uniqueness: { case_sensitive: false }, 
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  
  before_save :downcase_email
  
  # Role methods
  def admin?
    is_admin == true
  end
  
  def customer?
    !is_admin
  end
  
  private
  
  def downcase_email
    self.email = email.downcase if email.present?
  end
end
