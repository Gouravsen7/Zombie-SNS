FactoryBot.define do
  factory(:survivor) do
    name { 'steve' }
    age { 22 }
    gender { 'female' }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    infected { false }
  end

  factory(:reported_survivor) do
    reported_to { FactoryBot.create(:survivor).id }
    reported_by { FactoryBot.create(:survivor).id }
  end

  factory(:item) do
  	item { 'water' }
  	survivor_id { FactoryBot.create(:survivor).id }
  	points { 14 }
  	quantity { 2 }
  end

end