require 'rails_helper'

RSpec.describe "creating user", :type => :request do
  it "fails with 400 if user is empty" do
    post api_v1_register_path, params: { user: {}}

    expect(response).to have_http_status(:bad_request)
  end
  
  it "fails with 400 if username is to short" do
    user_params = FactoryBot.attributes_for(:random_user).merge(username: "al")
    post api_v1_register_path, params: { user: user_params}

    expect(response).to have_http_status(:bad_request)
  end

  it "fails with 400 if password is to short" do
    user_params = FactoryBot.attributes_for(:random_user).merge(password: "al")
    post api_v1_register_path, params: { user: user_params }

    expect(response).to have_http_status(:bad_request)
  end

  it "works if all parameters are valid" do
    user_params = FactoryBot.attributes_for(:random_user)
    post api_v1_register_path, params: { user: user_params }

    expect(response).to have_http_status(:ok)
  end

  it "fails if username is taken" do
    user_params = FactoryBot.attributes_for(:random_user)
    post api_v1_register_path, params: { user: user_params }

    expect(response).to have_http_status(:ok)

    user_params2 = FactoryBot.attributes_for(:random_user).merge(username: user_params[:username] )
    post api_v1_register_path, params: { user: user_params2 }
    expect(response).to have_http_status(:bad_request)
  end

  it "fails if email is taken" do
    user_params = FactoryBot.attributes_for(:random_user)
    post api_v1_register_path, params: { user: user_params }

    expect(response).to have_http_status(:ok)

    user_params2 = FactoryBot.attributes_for(:random_user).merge(email: user_params[:email])
    post api_v1_register_path, params: { user: user_params2 }
    expect(response).to have_http_status(:bad_request)
  end

end
