class AddImgUrlToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :img_url, :string
  end
end
