require_relative 'concerns/tables'
class Party < ActiveRecord::Base
	has_many :orders
	has_many :foods, through: :orders
	belongs_to :receipt
	belongs_to :employee

	# include Tables
	def self.open_tables
		range = (1..10)
		table = range.to_a
		parties = Party.all
		not_paid = parties.where(paid: 'f')
		unavailable = not_paid.map do |table|
			table.table_number
		end
		return available = table - unavailable
	end

	def self.used_tables
		range = (1..10)
		table = range.to_a
		parties = Party.all
		not_paid = parties.where(paid: 'f')
		unavailable = not_paid.map do |table|
			table.table_number
		end
		return unavailable
	end
end