FactoryBot.define do

  factory :random_flower, class: Flower do
    name { Faker::Lorem.characters(number: 10, min_alpha: 10) }
    description { 3.times.map { |i| Faker::Lorem.paragraph }.join(". ") }

    after(:create) do |flower|
      f = File.open(Rails.root.join('storage', 'flowers', '1.jpg'))
      flower.image.attach(io: f, filename: '1.jpg', content_type: 'image/jpeg')
      flower.save!
    end

  end

end