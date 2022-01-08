require 'rails_helper'

RSpec.describe Like, type: :model do
  let(:flower) { FactoryBot.create(:random_flower) }
  let(:user) { FactoryBot.create(:random_user) }
  let(:sighting) {
    sighting = FactoryBot.build(:random_sighting_params)
    sighting.flower_id = flower.id
    sighting.user_id = user.id
    sighting.save!
    sighting
  }

  it "is not valid when empty" do
    empty = Like.new
    expect(empty).not_to be_valid
  end

  it "is not valid when user already liked the same sighting" do
    like1 = Like.create(sighting_id: sighting.id, user_id: user.id)
    like2 = Like.new(sighting_id: sighting.id, user_id: user.id)

    expect(like1).to be_valid
    expect(like2).not_to be_valid
  end
end
