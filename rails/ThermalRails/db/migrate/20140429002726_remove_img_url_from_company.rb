class RemoveImgUrlFromCompany < ActiveRecord::Migration
  def change
    remove_column :companies, :img_url, :string
  end
end
