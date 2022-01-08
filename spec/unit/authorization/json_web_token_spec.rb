require 'rails_helper'

include Jwt

RSpec.describe JsonWebToken do
  let(:user) { FactoryBot.create(:random_user) }

  it "creates a valid token and verify it successfully" do
    token = JsonWebToken.create_token(user, UUID.generate)

    payload = JsonWebToken.verify_token(token)

    expect(payload["user_id"]).to eq(user.id)
  end
end
