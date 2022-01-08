class Sighting < ApplicationRecord
  include Validations::SightingValidation

  include Hooks::SightingHooks

  belongs_to :flower
  belongs_to :user
  has_one_attached :image, dependent: :destroy
  has_many :likes, dependent: :destroy

  self.per_page = 10
end
