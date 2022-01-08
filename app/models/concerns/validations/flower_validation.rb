module Validations
  module FlowerValidation extend ActiveSupport::Concern

    included do
      validates :name, presence: true, length: { minimum: 3, maximum: 128 }, uniqueness: true
      validates :description, presence: true, length: { minimum: 16 }
    end
  end
end
