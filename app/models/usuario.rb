class Usuario < ActiveRecord::Base
  has_and_belongs_to_many :rols
  belongs_to :suscriptor

  validates_uniqueness_of :codigo, :login

  validates_associated :rols, :suscriptor

  validates_presence_of :codigo, :nombre, :suscriptor_id

  cattr_reader :per_page
  @@per_page = 10

  attr_accessor :password_confirmation, :rol_list
  validates_confirmation_of :password
  validate :password_non_blank
  before_save :update_rols
  #before_update :update_rols

  def self.authenticate(login,password)
    usuario = self.find_by_login(login)
    if usuario
      expected_password = encrypted_password(password, usuario.salt)
      if usuario.hashed_password != expected_password
        usuario = nil
      end
    end
    usuario
  end

  def password
    @password
  end

  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = Usuario.encrypted_password(self.password, self.salt)
  end

  def after_destroy
    if Usuario.count.zero?
      raise "No se puede eliminar el Único usuario existente"
    end
  end

  private
  def password_non_blank
    errors.add(:password, "Debe indicar un valor en Password") if hashed_password.blank?
  rescue
  end

  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end

  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

  def update_rols
    self.rols.delete_all
    rol_list.each {|value| #Agregamos a la colecció los roles en el arreglo...
      @rols = self.rols << Rol.find(value)
    }
  end
end
