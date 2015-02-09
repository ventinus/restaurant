class Receipt < ActiveRecord::Base
	belongs_to :party
	has_many :orders, through: :party
	has_many :foods, through: :orders
end