require 'redis'

module Jwt
  class JsonWebToken

    @@redis_client = Redis.new(host: Rails.application.config.redis_host)

    def self.duration
      ENV['JWT_TOKEN_DURATION'].to_i.minutes
    end

    def self.token_key(user_id, device_id)
      user_id.to_s + ":" + device_id.to_s
    end

    def self.create_payload(user, device_id)
      { user_id: user.id, device_id: device_id, expires: Time.now + duration }
    end

    def self.create_token(user, device_id)
      payload = create_payload(user, device_id)
      token = JWT.encode(payload, secret, 'HS256')

      key = token_key(user.id, device_id)
      @@redis_client.set(key, true, ex: duration.to_i)
      token
    end

    def self.destroy_token(token)
      payload = verify_token(token)

      payload && @@redis_client.del(token_key(payload["user_id"], payload["device_id"]))
    end

    def self.secret
      ENV["SECRET_KEY"]
    end

    def self.extract_user_id(token)
      verified_payload = verify_token(token)

      verified_payload["user_id"] if verified_payload
    end

    def self.verify_token(token)
      return nil unless token

      begin
        decoded_token = JWT.decode(token, secret, false, { algorithm: 'HS256' })

        payload = decoded_token[0]
        token_exists = @@redis_client.get(token_key(payload["user_id"], payload["device_id"]))

        payload if token_exists
      rescue JWT::DecodeError
        nil
      end
    end
  end
end
