class CcpInicio < ActiveRecord::Migration
  def self.up
    create_table :clientes do |t|
      t.string :codigo, :limit => 6, :null => false
      t.string :nombre, :limit=>65, :null => false
      t.string :nombre_completo, :limit=>120, :null => false
      t.string :logo, :limit=>45, :default => 'NoLogo.jpg', :null => true
      t.string :direccion, :limit=>65, :null => true
      t.string :pais, :limit=>3, :null => true
      t.string :estado, :limit=>3, :null => true
      t.string :ciudad, :limit=>45, :null => true
      t.string :zp, :limit=>15, :null => true
      t.string :telefono1, :limit=>15, :null => true
      t.string :telefono2, :limit=>15, :null => true
      t.string :telefono3, :limit=>15, :null => true
      t.string :fax, :limit=>15, :null => true
      t.string :email, :limit=>120, :null => true
      t.string :web, :limit=>120, :null => true
      t.string :idioma, :limit=>3, :null => false
      t.integer :suscriptor_id
      t.integer :moneda_id
      t.timestamps
    end

    create_table :contactos_clientes do |t|
      t.string :codigo, :limit => 6, :null => false
      t.string :nombres, :limit=>45, :null => false
      t.string :apellidos, :limit=>45, :null => false
      t.string :cargo, :limit=>65, :null => true
      t.string :telefono1, :limit=>15, :null => true
      t.string :telefono2, :limit=>15, :null => true
      t.string :fax, :limit=>15, :null => true
      t.string :email, :limit=>120, :null => true
      t.string :observaciones, :limit=>250, :null => true
      t.string :estatus, :limit=>3, :default => 'ACT', :null => false
      t.integer :cliente_id
      t.timestamps
    end

    create_table :proyectos do |t|
      t.string :codigo, :limit => 8, :null => false
      t.string :nombre, :limit=>65, :null => false
      t.string :descripcion, :limit=>250, :null => true
      t.string :estatus, :limit=>3, :default=>'NVO', :null => true
      t.integer :horas_plan_original, :limit=>6, :default=>0
      t.integer :horas_plan_actual, :limit=>6, :default=>0
      t.date    :fecha_inicio_original, :null => false
      t.date    :fecha_inicio_actual, :null => false
      t.date    :fecha_inicio_real, :null => false
      t.date    :fecha_fin_original, :null => false
      t.date    :fecha_fin_actual, :null => false
      t.date    :fecha_fin_real, :null => false
      t.integer :cliente_id
      t.integer :suscriptor_id
      t.integer :contacto_cliente_id
      t.integer :moneda_id
      t.timestamps
    end
  end

  def self.down
    drop_table :clientes
    drop_table :contactos_clientes
    drop_table :proyectos
  end
end
