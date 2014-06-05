#Basic Company model where one ActiveRecord is a single company's name, along with its votes and comparisons
class Company < ActiveRecord::Base
	has_many :votes
	has_many :comparisons
end
