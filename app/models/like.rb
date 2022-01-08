class Like < ApplicationRecord
  include Validations::LikeValidation

  belongs_to :sighting
  belongs_to :user
end
