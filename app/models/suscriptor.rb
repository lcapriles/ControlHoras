class Suscriptor < ActiveRecord::Base
  has_many :usuarios
  
  validates_uniqueness_of :codigo
  validates_presence_of :codigo, :nombre

  before_save :update_logo

  def update_logo
    if self.logo_changed?
      self.logo_img = self.logo.read
      self.logo_type = self.logo.content_type.chomp
      self.logo = self.logo.original_filename.gsub(/[^\w._-]/, '')
    end
  end
end
