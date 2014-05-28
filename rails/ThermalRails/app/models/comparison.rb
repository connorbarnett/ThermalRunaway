#Comparison model where one ActiveRecord is a single comparison cast by a user on the iPhone app
class Comparison < ActiveRecord::Base
	belongs_to :winning_company, :foreign_key => "winning_company_id", :class_name => "Company"
	belongs_to :losing_company, :foreign_key => "losing_company_id", :class_name => "Company"
end
