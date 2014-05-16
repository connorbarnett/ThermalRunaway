class Company < ActiveRecord::Base
	has_many :votes
	has_many :comparisons
end
