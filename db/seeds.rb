require 'json'

include ImageLoaders

imagesLoader = FsImageLoader.new
images = imagesLoader.load_flowers_images


# factories could be used for generating seed data, but as FActoryGirl author argues against using it in seeds, I prefer to not to it
flower_names = [
  "Abutilon",
  "Alcacia",
  "Dandelion",
  "Rose",
  "Violet",
  "Blazing Star",
  "Bletilla",
  "Tagetes",
  "Lillium",
  "Cardinal Flower"
]

description = "A flower, sometimes known as a bloom or blossom, is the reproductive structure found in flowering plants
 (plants of the division Magnoliophyta, also called angiosperms). The biological function of a flower is to facilitate reproduction,
usually by providing a mechanism for the union of sperm with eggs. Flowers may facilitate
outcrossing (fusion of sperm and eggs from different individuals in a population) resulting from
cross-pollination or allow selfing (fusion of sperm and egg from the same flower) when self-pollination occurs."

flowers_attrs = flower_names.map { |name| { name: name, description: description } }

ActiveRecord::Base.transaction do
  begin
    flowers_models = Flower.create!(flowers_attrs)
    flowers_models.each do |f|
      img = images.sample
      f.image.attach(io: File.open(img), filename: img)
      f.save!
    end

    user_attrs = {
      username: 'aldm',
      email: 'amer.zildzic@gmail.com',
      password: ENV['TEST_PASS'],
      password_confirmation: ENV['TEST_PASS']
    }

    User.create!(user_attrs)

    Rails.logger.info "Data seeded to DB"
  rescue => ex
    Rails.logger.error "Error on seeding data: #{ex.message}. Will do rollback..."
    raise ActiveRecord::Rollback
  end
end

