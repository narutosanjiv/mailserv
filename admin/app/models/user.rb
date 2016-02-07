class User
  include Mongoid::Document
  
  authenticates_with_sorcery!
  
  field :name, type: String
  field :is_admin, type: Boolean

  belongs_to :domain  

  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes["password"] }
  validates :password, confirmation: true, if: -> { new_record? || changes["password"] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes["password"] }

  validates :email, uniqueness: true
end
