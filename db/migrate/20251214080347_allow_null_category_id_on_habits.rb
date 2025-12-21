class AllowNullCategoryIdOnHabits < ActiveRecord::Migration[7.2]
  def change
    change_column_null :habits, :category_id, true
  end
end
