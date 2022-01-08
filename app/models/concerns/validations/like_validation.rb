module Validations
  module LikeValidation
    extend ActiveSupport::Concern

    included do
      validates_uniqueness_of :user_id, scope: %i[sighting_id]
    end
  end
end
