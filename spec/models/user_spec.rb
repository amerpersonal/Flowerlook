require 'rails_helper'

RSpec.describe User, type: :model do
  let(:empty) { User.new }

  it "is not valid when empty" do
    expect(empty).to_not be_valid
  end

  it "is not valid without password" do
    user = User.new(username: 'test', email: 'test@test.com')
    expect(user).to_not be_valid
  end

  it "is not valid without username" do
    user = User.new(password: 'test1234', email: 'test@test.com')
    expect(user).to_not be_valid
  end

  it "is not valid without email" do
    user = User.new(password: 'test1234', username: 'test')
    expect(user).to_not be_valid
  end

  it "is not valid with to short username" do
    user = User.new(password: 'test1234', username: 'tes', email: 'test@test.com')
    expect(user).to_not be_valid
  end

  it "is not valid with to short password" do
    user = User.new(password: 'te', username: 'test', email: 'test@test.com')
    expect(user).to_not be_valid
  end

  it "is not valid with only letters in password" do
    user = User.new(password: 'testtest', username: 'test', email: 'test@test.com')
    expect(user).to_not be_valid
  end

  it "is not valid with no special chars password" do
    user = User.new(password: 'Test1234', username: 'test', email: 'test@test.com')
    expect(user).to_not be_valid
  end

  it "is valid with all valid attributes" do
    user = User.new(password: 'Test_1234', password_confirmation: 'Test_1234', username: 'test', email: 'test@test.com')
    expect(user).to be_valid
  end

  it "cannot create 2 users with same username" do
    user1 = User.new(password: 'Test_1234', password_confirmation: 'Test_1234', username: 'test', email: 'test2@test.com')
    user1.save

    user2 = User.new(password: 'Test_1234', password_confirmation: 'Test_1234', username: 'test', email: 'test2@test.com')
    user2.save

    expect(user1).to be_valid
    expect(user2).to_not be_valid
  end

  it "cannot create 2 users with same email" do
    user1 = FactoryBot.build(:random_user)
    user1.save

    user2 = FactoryBot.build(:random_user)
    user2.email = user1.email
    user2.save

    expect(user1).to be_valid
    expect(user2).to_not be_valid
  end

  it "cannot create user without @ in email" do
    user = User.new(password: 'Test_1234', username: 'test', email: 'test.com')
    expect(user).to_not be_valid
  end

  it "cannot create user without . in email" do
    user = User.new(password: 'Test_1234', username: 'test', email: 'test@t.')
    expect(user).to_not be_valid
  end

end

