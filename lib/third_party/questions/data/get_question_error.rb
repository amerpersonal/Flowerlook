module ThirdParty
  module Questions
    module Data
      # class that represents non timeout error returned from API https://opentdb.com/api.php
      class GetQuestionError
        attr_reader :error

        def initialize(err)
          @error = err
        end

        def deconstruct
          [error]
        end

        def deconstruct_keys
          { error: error }
        end
      end

    end
  end
end