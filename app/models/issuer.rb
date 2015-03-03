# == Schema Information
#
# Table name: issuers
#
#  id                  :integer          not null, primary key
#  tax_id              :string
#  company_name        :string           default("")
#  trade_name          :string
#  email               :string
#  password_digest     :string
#  person_type_code    :string           default("J")
#  residence_type_code :string           default("R")
#  address             :string
#  postal_code         :string
#  town                :string
#  province            :string
#  country_code        :string           default("ESP")
#  certificate         :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Issuer < ActiveRecord::Base
  has_many :invoices, :dependent => :delete_all
  has_secure_password
  attr_accessor :remember_token

  before_save { self.email = email.downcase }

  validates :tax_id, presence: true, uniqueness: true, nif: true
  validates :company_name, presence: true, length: { in: 4..80}
  validates :trade_name, length: { in: 0..40}
  validates :email, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :password, presence: true, length: { in: 4..16 }
  validates :person_type_code, presence: true,
    inclusion: { in: %w(F J), message: "%{value} must be 'F' for Individual or 'J' for Legal Entity." }
  validates :residence_type_code, presence: true,
    inclusion: { in: %w(E R U), message: "%{value} must be 'E'-Foreigner; 'R'-Resident in Spain; 'U'Resident in other EU country." }
  validates :address, presence: true, length: {in: 1..80}
  validates :postal_code, presence: true, format: { with: /\A\d{5}\z/i }
  validates :town, presence: true, length: {in: 1..20}
  validates :province, presence: true, length: {in: 1..20}
  validates :country_code, presence: true, length: {is: 3}

  # This code is from : https://www.railstutorial.org/book/log_in_log_out#sec-remember_me
  # Returns the hash digest of the given string.
  def Issuer.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def Issuer.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a issuer in the database for use in persistent sessions.
  def remember
    self.remember_token = Issuer.new_token
    # IMPORTANT! this method bypasses the validations
    update_attribute(:remember_digest, Issuer.digest(remember_token))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a issuer.
  def forget
    update_attribute(:remember_digest, nil)
  end
end
