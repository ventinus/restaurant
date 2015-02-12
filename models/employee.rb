class Employee < ActiveRecord::Base
	attr_reader :password
	has_many :parties
	has_many :orders, through: :parties

	validates :username, uniqueness: true, presence: true
	validates :password_digest, presence: true
	validates :password, length: {minimum: 6, allow_nil: true}

	def self.find_by_credentials(args={})
		employee = Employee.find_by(username: args[:username])

		if employee.is_password?(args[:password])
			return employee
		else
			return nil
		end
	end

	def password=(pword)
		@password = pword
		self.password_digest = BCrypt::Password.create(pword)
		self.save
	end

	def is_password?(pword)
		bcrypt_pword = BCrypt::Password.new(self.password_digest)
		return bcrypt_pword.is_password?(pword)
	end
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