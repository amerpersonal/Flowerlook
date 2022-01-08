require 'rails_helper'

RSpec.describe Sighting, type: :model do
  let(:flower) { FactoryBot.create(:random_flower) }
  let(:user) { FactoryBot.create(:random_user) }

  it "is not valid when empty" do
    empty = Sighting.new
    expect(empty).not_to be_valid
  end

  it "is not valid without latitude" do
    sighting = Sighting.new(longitude: 2)
    expect(sighting).not_to be_valid
  end

  it "is not valid without longitude" do
    sighting = Sighting.new(latitude: 2)
    expect(sighting).not_to be_valid
  end

  it "is not valid if sighting with the same lat/lon exists" do
    sighting1 = Sighting.create(latitude: 2, longitude: 2, flower_id: flower.id, user_id: user.id)
    sighting2 = Sighting.create(latitude: 2, longitude: 2, flower_id: flower.id, user_id: user.id)

    expect(sighting1).to be_valid
    expect(sighting2).not_to be_valid
  end
end
