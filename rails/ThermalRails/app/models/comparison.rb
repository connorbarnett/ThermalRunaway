class Comparison < ActiveRecord::Base
	belongs_to :winning_company, :foreign_key => "winning_company_id", :class_name => "Company"
	belongs_to :losing_company, :foreign_key => "losing_company_id", :class_name => "Company"
end
