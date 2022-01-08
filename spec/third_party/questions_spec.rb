require 'rails_helper'
require 'third_party/questions/questions_api'

include ThirdParty::Questions
include ThirdParty::Questions::Data

RSpec.describe QuestionsApi do

  let(:questions_api) { QuestionsApi.new }

  it "fetches a question successfully" do
    result = questions_api.get_question

    expect(result).to be_a_kind_of(Question)
    expect(result.question).to_not be_nil
    expect(result.question).to_not be_empty
  end
  
end
