class Product < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, length: { minimum: 2, maximum: 255 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :open_price, presence: true, numericality: { greater_than: 0 }
  validates :price_per_bid, presence: true, numericality: { greater_than: 0 }
end
