require 'rails_helper'

include Validators::Common

RSpec.describe Validators::Common do
  it "empty password is invalid" do
    expect(valid_password?("")).to eq(false)
  end

  it "only letters password is invalid" do
    expect(valid_password?("abcdefgh")).to eq(false)
  end

  it "only digits password is invalid" do
    expect(valid_password?("00000000")).to eq(false)
  end

  it "only special chars password is invalid" do
    expect(valid_password?("++++++++")).to eq(false)
  end

  it "marks valid passwords as valid" do
    passwords = 10.times.map { |_| FactoryBot.generate(:random_password) }

    passwords.each do |password|
      expect(valid_password?(password)).to eq(true)
    end
  end
end
