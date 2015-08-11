class CreateRewards < ActiveRecord::Migration
  def change
    create_table :rewards do |t|
      t.string :subject
      t.integer :amount
      t.references :team, index: true

      t.timestamps
    end
  end
end
