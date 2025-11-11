class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :surname, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
end
