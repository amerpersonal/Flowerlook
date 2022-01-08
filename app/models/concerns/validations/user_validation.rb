module Validations
  module UserValidation
    extend ActiveSupport::Concern

    include Validators::Common

    included do
      validates :username, presence: true, length: { minimum: 4, maximum: 32 }, uniqueness: true
      validates :email, presence: true, length: { maximum: 64 }, format: { with: EMAIL_REGEX_PATTERN }, uniqueness: true

      validates :password, presence: true
      validates :password_confirmation, presence: true

      validate :validate_password

      def validate_password
        if password.present? && !valid_password?(password)
          errors.add(:password, "invalid. Should contain at least one uppercase char, downcase char, digit and special char")
        end
      end
    end
  end
end
