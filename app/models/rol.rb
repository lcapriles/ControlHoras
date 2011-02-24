class Rol < ActiveRecord::Base
  validates_uniqueness_of :codigo

  validates_presence_of :codigo, :message => ' - ódigo Invalido'
  validates_presence_of :nombre, :message => ' - Nombre Invalido'

  cattr_reader :per_page
  @@per_page = 10
end
