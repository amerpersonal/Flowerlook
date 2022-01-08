module ThirdParty
  module Questions

    # class for working with API https://opentdb.com/api.php
    class QuestionsApi
      attr_reader :get_token_url
      attr_reader :params
      attr_reader :url
      attr_reader :redis_client

      include Data

      def initialize
        @url = ENV['QUESTION_API_URL']
        @params = {
          category: ENV['QUESTION_API_CATEGORY_ID'],
          amount: 1
        }
        @get_token_url = ENV['GET_TOKEN_URL']
        @redis_client = Redis.new(host: ENV['REDIS_HOST'])

        @token = get_cached_token
        refresh_token unless @token
      end

      def get_cached_token
        redis_client.get("questions_token")
      end

      def cache_token(token)
        redis_client.set("questions_token", token)
      end

      def refresh_token
        Rails.logger.info("Refreshing token for questions API")
        connection = Faraday::Connection.new get_token_url
        response = connection.get

        body = JSON.parse(response.body)
        if body["response_code"] == 0
          Rails.logger.info("Question token refreshed")
          @token = body["token"]
          cache_token(@token)
        else
          raise "Invalid token request to url #{get_token_url}"
        end
      end

      def parse_success_response(body)
        status_code = body["response_code"].to_i

        case status_code
        in 0
          results = body["results"]
          Question.new(results[0]["question"])
        in 1
          Rails.logger.warn("Request to URL #{url} resulted in empty response")
          nil
        in 2
          raise "Invalid request to url #{request_url}. Check params"
        in 3 | 4
          TokenExpired.new("Token expired")
        else
          raise "Invalid status code returned: #{body.inspect}. Check documentation please"
        end
      end

      def request_params
        @params.merge(token: @token)
      end

      # function that returns a single question from API https://opentdb.com/api.php
      def get_question
        connection = Faraday::Connection.new url, params: request_params
        response = connection.get

        case response.status
        in 200
          body = JSON.parse(response.body)

          parsed = parse_success_response(body)
          case parsed
          in TokenExpired[_]
            refresh_token
            get_question
          else
            parsed
          end
        in 408
          GetQuestionTimeout.new
        else
          GetQuestionError.new("Request to URL #{url} failed with #{response.status}")
        end
      end

    end
  end
end

