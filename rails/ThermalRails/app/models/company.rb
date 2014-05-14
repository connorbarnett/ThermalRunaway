class Company < ActiveRecord::Base
	has_many :votes
	has_many :comparisons
	has_many :compares, :through => :comparisons 
end
