class Employee < ActiveRecord::Base
	has_many :parties
	has_many :orders, through: :parties

	validates :name, uniqueness: true, presence: true
end


# class Employee < ActiveRecord::Base
#   has_many :parties

#   validates :name, uniqueness: true, presence: true

#   def find_open_parties
#     parties = self.parties

#     open_parties = parties.select do |party|
#       party.created_at.to_date > Date.yesterday &&
#       party.paid == false
#     end 
#     return open_parties
#   end

# end