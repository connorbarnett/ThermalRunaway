json.array!(@companies) do |company|
  json.extract! company, :id, :name, :img_url
  json.url company_url(company, format: :json)
end
