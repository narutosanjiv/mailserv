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
  
  before_save :create_email_from_domain  

  def json_presentation
    as_json(only: [:_id, :name, :is_admin, :email])
  end


  private

    def create_email_from_domain
      self.email = self.email.try(:strip) + "@" + self.domain.name if self.email
    end
end
