require 'rails_helper'

include Authentication::Authenticator

RSpec.describe "manipulating sightings", :type => :request do
  let(:flower) { FactoryBot.create(:random_flower) }
  let(:new_flower) { FactoryBot.create(:random_flower) }

  let(:user1) { FactoryBot.create(:random_user) }
  let(:user2) { FactoryBot.create(:random_user) }

  let(:device_id) { UUID.generate }

  let(:sighting) { create_sighting(flower, user1) }

  it "returns 404 when listing sightings for non existing flower" do
    get api_v1_flower_sightings_path(flower.id + 1)
    expect(response).to have_http_status(:not_found)
  end

  it "returns empty list of sightings for new flower" do
    get api_v1_flower_sightings_path(new_flower.id)

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body).to be_a_kind_of(Array)
    expect(body).to be_empty
  end

  it "not logged in user cannot create a sighting" do
    post api_v1_flower_sightings_path(new_flower.id), params: FactoryBot.attributes_for(:random_sighting_params)

    expect(response).to have_http_status(:unauthorized)
  end

  it "logged in user can create a sighting" do
    token = do_login(user1, device_id)["token"]
    create_sighting_via_api(flower, Authorization: auth_request_header(token))

    expect(response).to have_http_status(:ok)
  end

  it "returns non empty list of sightings for not logged in user" do
    token = do_login(user1, device_id)["token"]
    create_sighting_via_api(flower, Authorization: auth_request_header(token))

    get api_v1_flower_sightings_path(flower.id)

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body).to be_a_kind_of(Array)
    expect(body.size).to eq(1)
  end

  it "returns correct number of sightings when page specified" do
    total = 15
    per_page = 10
    total.times { create_sighting(flower, user1) }

    get api_v1_flower_sightings_path(flower.id), params: { page: 1 }
    body = response.parsed_body
    expect(body.size).to eq(per_page)

    get api_v1_flower_sightings_path(flower.id), params: { page: 2 }
    body = response.parsed_body
    expect(body.size).to eq(total-per_page)
  end

  it "returns empty list of sightings for not logged in user" do
    get api_v1_flower_sightings_path(flower.id)

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body).to be_a_kind_of(Array)
    expect(body).to be_empty
  end

  it "returns empty list of sightings for logged in user" do
    body = do_login(user1, device_id)
    token = body["token"]

    get api_v1_flower_sightings_path(flower.id), headers: { Authorization: auth_request_header(token)  }

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body).to be_a_kind_of(Array)
    expect(body).to be_empty
  end

  it "non logged in user cannot destroy sighting" do
    token = do_login(user1, device_id)["token"]

    body = create_sighting_via_api(flower, { "Authorization": auth_request_header(token)})
    sighting_id = body["id"]

    delete api_v1_flower_sighting_path(flower.id, sighting_id)
    expect(response).to have_http_status(:unauthorized)
  end

  it "logged in user cannot destroy sighting created by another user" do
    token = do_login(user1, device_id)["token"]

    body = create_sighting_via_api(flower, { "Authorization": auth_request_header(token)})
    sighting_id = body["id"]

    token = do_login(user2, device_id)["token"]
    delete api_v1_flower_sighting_path(flower.id, sighting_id), headers: { "Authorization": auth_request_header(token) }
    expect(response).to have_http_status(:not_found)
  end

  it "logged in user can destroy his own sighting" do
    token = do_login(user1, device_id)["token"]

    body = create_sighting_via_api(flower, { "Authorization": auth_request_header(token)})
    sighting_id = body["id"]

    token = do_login(user1, device_id)["token"]
    delete api_v1_flower_sighting_path(flower.id, sighting_id), headers: { "Authorization": auth_request_header(token) }
    expect(response).to have_http_status(:ok)
  end
end

