module ThirdParty
  module Questions
    module Data
      # class that represents a question returned from API https://opentdb.com/api.php
      class Question < GetQuestionResponse
        attr_reader :question

        def initialize(qst)
          @question = qst
        end

        def deconstruct
          [question]
        end

        def deconstruct_keys
          { question: question }
        end
      end
    end
  end
end


