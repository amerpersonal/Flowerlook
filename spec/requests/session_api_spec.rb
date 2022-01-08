require 'rails_helper'
require 'uuid'

include Authentication::Authenticator

RSpec.describe "sessions manipulation", :type => :request do
  let(:user) { FactoryBot.create(:random_user) }

  let(:device_id) { UUID.generate }

  it "fails to log in user without password provided" do
    post api_v1_login_path, params: { username: "aldm" }

    expect(response).to have_http_status(:bad_request)
  end

  it "fails to log in user without username provided" do
    post api_v1_login_path, params: { password: "aldm" }

    expect(response).to have_http_status(:bad_request)
  end

  it "fails to log in user for invalid username" do
    post api_v1_login_path, params: { username: user.username + "a", password: ENV['TEST_PASS'] }

    expect(response).to have_http_status(:bad_request)
  end

  it "fails to log in user for invalid password" do
    post api_v1_login_path, params: { username: user.username, password: ENV['TEST_PASS'] + "a" }

    expect(response).to have_http_status(:bad_request)
  end


  it "fails to log in user without device_id" do
    post api_v1_login_path, params: { username: user.username, password: ENV['TEST_PASS'] }

    expect(response).to have_http_status(:bad_request)
  end

  it "succeed to log in user for valid request" do
    do_login(user, device_id)
  end

  it "produces a valid response on login request" do
    body = do_login(user, device_id)
    expect(body).to include("user_id", "token")
    expect(body["user_id"]).to eq(user.id)
  end

  it "creates a valid auth token for later use" do
    body = do_login(user, device_id)
    token = body["token"]

    get api_v1_profile_path, headers: { Authorization: auth_request_header(token) }
    expect(response).to have_http_status(:ok)
    body = response.parsed_body

    expect(body["id"]).to eq(user.id)
    expect(body["username"]).to eq(user.username)
  end

  it "fails to log out user correctly when invalid token passed in header" do
    body = do_login(user, device_id)
    token = body["token"]

    delete api_v1_logout_path, headers: { Authorization: auth_request_header("a" + token) }
    expect(response).to have_http_status(:unauthorized)
  end

  it "succeed to log out user correctly when valid token passed in header" do
    body = do_login(user, device_id)
    token = body["token"]

    do_logout(token)
  end

  it "disables user to use token after log out" do
    body = do_login(user, device_id)
    token = body["token"]

    do_logout(token)

    get api_v1_profile_path, headers: { Authorization: auth_request_header(token) }
    expect(response).to have_http_status(:unauthorized)
  end

end
