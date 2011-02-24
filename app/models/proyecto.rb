class Proyecto < ActiveRecord::Base
  belongs_to :cliente
  belongs_to :suscriptor

  validates_uniqueness_of :codigo
  validates_presence_of :codigo, :nombre
  
  cattr_reader :per_page
  @@per_page = 10
end
