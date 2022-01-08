require 'uuid'

module Validators
  module Common

    EMAIL_REGEX_PATTERN = /\A(.+)@(.+)\.(.+)\z/

    def numeric?(c)
      c.match?(/[[:digit:]]/)
    end

    def upper_char?(c)
      c.match?(/[[:upper:]]/)
    end

    def lower_char?(c)
      c.match?(/[[:lower:]]/)
    end

    def valid_device_id?(device_id)
      device_id && UUID.validate(device_id)
    end

    # recursive function for checking in password is valid
    # password is valid if it contains at least 8 characters, with at least one upper letter, one lower letter, one digit and one special character
    # regex is alternative to using this function
    def valid_password?(password, index = 0, uc = 0, lc = 0, dc = 0, sc = 0)
      if index > password.size - 1
        uc > 0 && lc > 0 && dc > 0 && sc > 0
      elsif upper_char?(password[index])
        valid_password?(password, index + 1, uc + 1, lc, dc, sc)
      elsif lower_char?(password[index])
        valid_password?(password, index + 1, uc, lc + 1, dc, sc)
      elsif numeric?(password[index])
        valid_password?(password, index + 1, uc, lc, dc + 1, sc)
      else
        valid_password?(password, index + 1, uc, lc, dc, sc + 1)
      end
    end

  end
end
