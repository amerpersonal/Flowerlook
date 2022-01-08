FactoryBot.define do
  sequence :random_password do
    base = Faker::Internet.password(min_length: 8, mix_case: true, special_characters: true)
    character_and_digits = Faker::Lorem.characters(number: 2, min_alpha: 1, min_numeric: 1) + "A"
    base + character_and_digits
  end

  factory :random_user, class: User do
    username { Faker::Name.name.gsub(" ", "") }
    password { FactoryBot.generate(:random_password) }
    password_confirmation { password }
    email { Faker::Internet.email }
  end
end
