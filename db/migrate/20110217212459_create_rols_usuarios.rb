class CreateRolsUsuarios < ActiveRecord::Migration
  def self.up
    create_table :rols_usuarios, :id => false  do |t|
      t.references :rol
      t.references :usuario
    end
  end

  def self.down
    drop_table :rols_usuarios
  end
end
