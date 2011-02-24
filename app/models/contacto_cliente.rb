class Contacto_cliente < ActiveRecord::Base
  belongs_to :cliente
  
  validates_presence_of :codigo, :nombres, :apellidos, :estatus
  
  cattr_reader :per_page
  @@per_page = 10
end
