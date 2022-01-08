require 'rails_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!
RSpec.describe Sightings::AddQuestionWorker, type: :worker do
  let(:user) { FactoryBot.create(:random_user) }
  let(:device_id) { UUID.generate }
  let(:flower) { FactoryBot.create(:random_flower) }

  it "should enqueue item when perform_async called" do
    expect(described_class.jobs.size).to eq(0)
    described_class.perform_async(1, false)
    assert_equal "default", described_class.queue
    expect(described_class).to have_enqueued_sidekiq_job(1, false)
  end

  it "should enqueue item on create sighting action" do
    expect(described_class.jobs.size).to eq(0)
    sighting = create_sighting(flower, user)
    expect(described_class.jobs.size).to eq(1)
    expect(described_class).to have_enqueued_sidekiq_job(sighting.id, true)

  end
end
