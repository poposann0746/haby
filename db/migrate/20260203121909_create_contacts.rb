class CreateContacts < ActiveRecord::Migration[7.2]
  def change
    create_table :contacts do |t|
      t.string :name, limit: 100
      t.string :email, null: false
      t.text :message, null: false 
      t.boolean :replied, null: false, default: false

      t.timestamps
    end

    add_index :contacts, :replied
    add_index :contacts, :created_at
  end
end
