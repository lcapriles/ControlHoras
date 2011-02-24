class AddLogo < ActiveRecord::Migration
  def self.up
    add_column :clientes, :logo_type, :string
    add_column :clientes, :logo_img, :binary, :limit => 1.megabyte
  end
    
  def self.down
    
  end
end
