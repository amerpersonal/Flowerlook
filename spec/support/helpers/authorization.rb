def do_login(user, device_id)
  post api_v1_login_path, params: { username: user.username, password: user.password, device_id: device_id }

  expect(response).to have_http_status(:ok)
  response.parsed_body
end

def do_logout(token)
  delete api_v1_logout_path, headers: { Authorization: auth_request_header(token) }
  expect(response).to have_http_status(:ok)
  response.parsed_body
end
