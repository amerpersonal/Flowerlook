class AddQuestionToSightings < ActiveRecord::Migration[6.1]
  def change
    add_column :sightings, :question, :text
  end
end
