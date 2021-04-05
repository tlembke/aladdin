class CreateClinics < ActiveRecord::Migration
  def change
    create_table :clinics do |t|
      t.date :clinicdate
      t.integer :starthour, :default => 10
      t.integer :startminute, :default => 0
      t.integer :finishhour, :default => 13
      t.integer :finishminute, :default => 0
      t.integer :perhour, :default => 0
      t.string :vaxtype, :default => "Flu"
      t.string :venue, :default => "Baptist Hall"
      t.boolean :template,:default => false
      t.integer :age, :default => 0
      t.integer :ATSIage,:default => 0
      t.boolean :chronic, :default => false
      t.integer :chronicage, :default => 0
      t.string :message 

      t.timestamps null: false
    end
  end
end
