def create_sighting_via_api(flower, headers)
  post api_v1_flower_sightings_path(flower.id), params: {
    sighting: FactoryBot.attributes_for(:random_sighting_params).merge(image: Rack::Test::UploadedFile.new(Dir.pwd + "/spec/requests/files/flowers/1.jpg"))
  }, headers: headers

  expect(response).to have_http_status(:ok)

  response.parsed_body
end

def create_sighting(flower, user)
  sighting_params = FactoryBot.attributes_for(:random_sighting_params).merge(user: user, flower: flower)
  sighting = Sighting.new(sighting_params)
  f = File.open(Rails.root.join('storage', 'flowers', '1.jpg'))
  sighting.image.attach(io: f, filename: '1.jpg', content_type: 'image/jpeg')
  sighting.save!
  sighting
end
