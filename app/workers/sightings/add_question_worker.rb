module Sightings

  # worker for adding question to Sighting
  class AddQuestionWorker
    include Sidekiq::Worker

    sidekiq_options retry: false

    def perform(sighting_id, do_retry)
      Rails.logger.info("Adding question for sighting #{sighting_id} with #{do_retry}")
      activity_service = GetQuestionService.new
      activity_service.add_question(sighting_id, do_retry)
    end
  end
end
