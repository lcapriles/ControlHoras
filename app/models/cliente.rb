class Cliente < ActiveRecord::Base
  has_many :contactos_clientes
  has_many :proyectos
  belongs_to :suscriptor
  
  validates_presence_of :codigo, :nombre, :nombre_completo, :idioma

  before_save :update_logo
  
  cattr_reader :per_page
  @@per_page = 10

  def update_logo
    if self.logo_changed?
      self.logo_img = self.logo.read
      self.logo_type = self.logo.content_type.chomp
      self.logo = self.logo.original_filename.gsub(/[^\w._-]/, '')
    end
  end

end
