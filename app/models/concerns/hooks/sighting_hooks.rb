module Hooks
  module SightingHooks extend ActiveSupport::Concern

    included do
      after_commit :add_question

      def add_question
        if persisted? && question.nil?
          Sightings::AddQuestionWorker.perform_async(id, true)
        end
      end
    end
  end

end