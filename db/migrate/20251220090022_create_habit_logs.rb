class CreateHabitLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :habit_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :habit, null: false, foreign_key: true
      #t.references :habit_schedule, null: false, foreign_key: true

      t.date :log_date, null: false
      t.datetime :logged_at
      t.boolean :is_taken, null: false, default: false


      t.timestamps
    end

    add_index :habit_logs, [:user_id, :habit_id, :log_date], unique: true
  end
end
