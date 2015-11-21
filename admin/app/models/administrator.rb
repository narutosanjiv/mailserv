class Administrator
  include Mongoid::Document
    
  authenticates_with_sorcery!

  field :email
  field :username
  field :crypted_password
  field :salt

  validates :username, presence: true, uniqueness: true
  validates :email, format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z/ }, allow_blank: true
  validates :password, presence: true, confirmation: true, on: :create
end
