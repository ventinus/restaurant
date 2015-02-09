class Order < ActiveRecord::Base
belongs_to :party
belongs_to :food
belongs_to :receipt
end