module Validations
  module SightingValidation
    extend ActiveSupport::Concern
    included do
      validates :latitude, presence: true
      validates :longitude, presence: true

      # we cannot have 2 different flowers on the exact same geo location
      validates_uniqueness_of :latitude, scope: %i[longitude]

    end
  end
end
