require 'rails_helper'

RSpec.describe Flower, type: :model do
  it "is not valid when empty" do
    empty = Flower.new
    expect(empty).not_to be_valid
  end

  it "is not valid when name is shorter than 3 characters" do
    flower = FactoryBot.create(:random_flower)
    flower.name = "ab"

    expect(flower).not_to be_valid
  end

  it "is not valid when description is shorter than 16 characters" do
    flower = FactoryBot.create(:random_flower)
    flower.description = "some chars"

    expect(flower).not_to be_valid
  end

  it "is valid when all properties are valid" do
    flower = FactoryBot.create(:random_flower)

    expect(flower).to be_valid
  end

  it "is not valid when name is not uniqie" do
    flower1 = FactoryBot.create(:random_flower)
    flower1.save
    flower2 = FactoryBot.create(:random_flower)
    flower2.name = flower1.name
    flower2.save

    expect(flower1).to be_valid
    expect(flower2).not_to be_valid
  end

end
