class AddScheduleDaysToHabits < ActiveRecord::Migration[7.2]
  def change
    add_column :habits, :schedule_days, :integer, array: true, default: []
    add_index :habits, :schedule_days, using: :gin
  end
end
