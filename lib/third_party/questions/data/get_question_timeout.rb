module ThirdParty
  module Questions
    module Data

      # class that represents a timeout returned from API https://opentdb.com/api.php
      class GetQuestionTimeout < GetQuestionResponse
        def deconstruct
          []
        end

        def deconstruct_keys
          {}
        end
      end
    end
  end
end
