class CreateUsuarios < ActiveRecord::Migration
  def self.up
    create_table :usuarios do |t|

      t.string :codigo
      t.string :nombre
      t.integer :estatus
      t.string :categoria
      t.string :login
      t.string :hashed_password
      t.string :salt

      t.integer :suscriptor_id

      t.timestamps
    end
  end

  def self.down
    drop_table :usuarios
  end
end
