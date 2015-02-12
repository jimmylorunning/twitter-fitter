class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :handle1
      t.string :handle2
      t.string :tweet

      t.timestamps
    end
  end
end
