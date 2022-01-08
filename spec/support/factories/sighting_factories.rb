FactoryBot.define do
  factory :random_sighting_params, class: Sighting do
    latitude { Faker::Number.decimal(l_digits: 3, r_digits: 3) }
    longitude { Faker::Number.decimal(l_digits: 3, r_digits: 3) }
  end
end
