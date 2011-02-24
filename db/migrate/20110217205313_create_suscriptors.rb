class CreateSuscriptors < ActiveRecord::Migration
  def self.up
    create_table :suscriptors do |t|
      t.string :codigo
      t.string :nombre
      t.string :logo, :limit=>45, :default => 'NoLogo.jpg', :null => true
      t.string :logo_type
      t.binary :logo_img, :limit => 1.megabyte

      t.timestamps
    end
  end

  def self.down
    drop_table :suscriptors
  end
end
