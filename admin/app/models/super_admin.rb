class SuperAdmin

  include Mongoid::Document
    
  authenticates_with_sorcery!

  field :email, type: String
  field :username, type: String
  field :crypted_password, type: String 
  field :salt, type: String  
  
end
