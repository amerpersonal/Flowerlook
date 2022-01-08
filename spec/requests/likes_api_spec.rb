require 'rails_helper'

include Authentication::Authenticator

RSpec.describe "likes", :type => :request do
  let(:flower) { FactoryBot.create(:random_flower) }
  let(:new_flower) { FactoryBot.create(:random_flower) }

  let(:user1) { FactoryBot.create(:random_user) }
  let(:user2) { FactoryBot.create(:random_user) }

  let(:device_id) { UUID.generate }

  it "cannot like sighting without token passed in request" do
    token = do_login(user1, device_id)["token"]
    sighting_id = create_sighting_via_api(flower, Authorization: token)["id"]

    post api_v1_flower_sighting_likes_path(flower.id, sighting_id)

    expect(response).to have_http_status(:unauthorized)
  end

  it "user can like his own sighting" do
    token = do_login(user1, device_id)["token"]
    sighting_id = create_sighting_via_api(flower, Authorization: token)["id"]

    post api_v1_flower_sighting_likes_path(flower.id, sighting_id), headers: { Authorization: auth_request_header(token) }

    expect(response).to have_http_status(:ok)
  end

  it "user can like his sighting created by another user" do
    token = do_login(user1, device_id)["token"]
    sighting_id = create_sighting_via_api(flower, Authorization: token)["id"]

    token = do_login(user2, device_id)["token"]
    post api_v1_flower_sighting_likes_path(flower.id, sighting_id), headers: { Authorization: auth_request_header(token) }

    expect(response).to have_http_status(:ok)
  end

  it "increments likes count after the like is associated" do
    token = do_login(user1, device_id)["token"]
    sighting_id = create_sighting_via_api(flower, Authorization: token)["id"]

    token = do_login(user2, device_id)["token"]
    post api_v1_flower_sighting_likes_path(flower.id, sighting_id), headers: { Authorization: auth_request_header(token) }
    expect(response).to have_http_status(:ok)

    get api_v1_flower_sightings_path(flower.id)
    body = response.parsed_body
    sighting = body[0]

    expect(sighting["likes_count"]).to eq(1)
  end

  it "decrements likes count after the like is removed" do
    token = do_login(user1, device_id)["token"]
    sighting_id = create_sighting_via_api(flower, Authorization: token)["id"]

    token = do_login(user2, device_id)["token"]
    post api_v1_flower_sighting_likes_path(flower.id, sighting_id), headers: { Authorization: auth_request_header(token) }
    expect(response).to have_http_status(:ok)

    get api_v1_flower_sightings_path(flower.id)
    body = response.parsed_body
    sighting = body[0]

    expect(sighting["likes_count"]).to eq(1)

    delete api_v1_flower_sighting_likes_path(flower.id, sighting_id), headers: { Authorization: auth_request_header(token) }
    expect(response).to have_http_status(:ok)

    get api_v1_flower_sightings_path(flower.id)
    body = response.parsed_body
    sighting = body[0]

    expect(sighting["likes_count"]).to eq(0)
  end

  it "disable user to remove like from item that he did not like" do
    token = do_login(user1, device_id)["token"]
    sighting_id = create_sighting_via_api(flower, Authorization: token)["id"]

    post api_v1_flower_sighting_likes_path(flower.id, sighting_id), headers: { Authorization: auth_request_header(token) }
    expect(response).to have_http_status(:ok)

    token = do_login(user2, device_id)["token"]

    delete api_v1_flower_sighting_likes_path(flower.id, sighting_id), headers: { Authorization: auth_request_header(token) }
    expect(response).to have_http_status(:not_found)
  end

  it "user can destroy his own like" do
    token = do_login(user1, device_id)["token"]
    sighting_id = create_sighting_via_api(flower, Authorization: token)["id"]

    token = do_login(user2, device_id)["token"]
    post api_v1_flower_sighting_likes_path(flower.id, sighting_id), headers: { Authorization: auth_request_header(token) }

    expect(response).to have_http_status(:ok)
  end
end
