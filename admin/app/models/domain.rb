class Domain
  include Mongoid::Document
  field :allowed_quota, type: Double
  field :max_allowed_quota, type: Double
  field :name, type: String 
  
end
