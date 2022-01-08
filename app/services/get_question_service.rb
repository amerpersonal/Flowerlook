class GetQuestionService
  attr_reader :sighting
  attr_reader :retry_in

  include ThirdParty::Questions
  include ThirdParty::Questions::Data

  def initialize
    @sighting = sighting
    @retry_in = ENV['ADD_QUESTION_RETRY_DELAY'].to_i
  end

  def add_question(sighting_id, do_retry = false)
    api = questions_api
    case api.get_question
    in Question[question]
      store_question_with_sighting(sighting_id, question)
    in GetQuestionTimeout if do_retry
      Rails.logger.error("Timeout on getting question from #{api.url} for sighting #{sighting_id}. Will retry in #{retry_in.minutes}")
      Sightings::AddQuestionWorker.perform_in(retry_in.minutes, sighting_id, false)
    in GetQuestionTimeout if !do_retry
      Rails.logger.error("Timeout on getting question from #{api.url} for sighting #{sighting_id}")
    in GetQuestionError[error]
      Rails.logger.error(error)
    end
  end

  def store_question_with_sighting(sighting_id, question)
    sighting = Sighting.find(sighting_id)
    if sighting
      sighting.question = question
      sighting.save!

      Rails.logger.info("Question added for sighting #{sighting.id}")
    else
      Rails.logger.warn("Sighting #{sighting_id} not found. Unable to add question to it")
    end
  end

  def questions_api
    QuestionsApi.new
  end

end

