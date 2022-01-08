class Flower < ApplicationRecord
  has_one_attached :image, dependent: :destroy

  has_many :sightings

  include Validations::FlowerValidation

  self.per_page = 10
end
