require 'rails_helper'

include Authentication::Authenticator

RSpec.describe "manipulating flowers", :type => :request do
  let(:user) { FactoryBot.create(:random_user) }
  let(:device_id) { UUID.generate }

  it "lists non empty list of flowers for not logged in user" do
    10.times.each { FactoryBot.create(:random_flower) }

    get api_v1_flowers_path

    body = response.parsed_body

    expect(response).to have_http_status(:ok)
    expect(body).to be_a_kind_of(Array)
    expect(body).to_not be_empty
  end

  it "lists non empty list of flowers for logged in user" do
    body = do_login(user, device_id)
    token = body["token"]

    10.times.each { FactoryBot.create(:random_flower) }
    get api_v1_flowers_path, params: {}, headers: { "Authorization": auth_request_header(token) }

    body = response.parsed_body

    expect(response).to have_http_status(:ok)
    expect(body).to be_a_kind_of(Array)
    expect(body).to_not be_empty
  end

  it "lists paginated flowers with page param correctly" do
    per_page = 10
    total = 14
    total.times.each { FactoryBot.create(:random_flower) }

    get api_v1_flowers_path, params: { page: 1 }
    paginated_items = response.parsed_body

    expect(paginated_items.size).to eq(per_page)

    get api_v1_flowers_path, params: { page: 2 }
    paginated_items = response.parsed_body

    expect(paginated_items.size).to eq(total - per_page)
  end

  it "listed items contain all required properties" do
    10.times.each { FactoryBot.create(:random_flower) }

    get api_v1_flowers_path
    items = response.parsed_body

    expect(items).to all(include("id", "name", "updated_at", "image"))
  end

  it "image paths valid on all listed items" do
    10.times.each { FactoryBot.create(:random_flower) }

    get api_v1_flowers_path
    items = response.parsed_body

    items.each do |item|
      get item["image"]
      expect(response).to have_http_status(:found)
    end
  end
end
