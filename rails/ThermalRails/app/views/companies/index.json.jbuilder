json.array!(@companies) do |company|
  json.extract! company, :id, :name, :up_votes, :down_votes
  json.url company_url(company, format: :json)
end
