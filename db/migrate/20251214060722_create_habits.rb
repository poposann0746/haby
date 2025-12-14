class CreateHabits < ActiveRecord::Migration[7.2]
  def change
    create_table :habits do |t|
      t.references :user, null: false, foreign_key: true

      t.bigint :category_id, null: false
      t.string :name, null: false, limit: 100
      t.text :detail
      t.integer :current_streak, null: false, default: 0
      t.integer :longest_streak, null: false, default: 0

      t.timestamps
    end

    add_index :habits, [:user_id, :name]
  end
end
