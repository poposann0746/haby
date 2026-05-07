class AddUniqueIndexToHabitsName < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL.squish
      DELETE FROM habit_logs
      WHERE habit_id IN (
        SELECT id FROM habits
        WHERE id NOT IN (
          SELECT MIN(id) FROM habits GROUP BY user_id, name
        )
      )
    SQL

    execute <<-SQL.squish
      DELETE FROM habits
      WHERE id NOT IN (
        SELECT MIN(id) FROM habits GROUP BY user_id, name
      )
    SQL

    remove_index :habits, [ :user_id, :name ]
    add_index :habits, [ :user_id, :name ], unique: true
  end

  def down
    remove_index :habits, [ :user_id, :name ]
    add_index :habits, [ :user_id, :name ]
  end
end
