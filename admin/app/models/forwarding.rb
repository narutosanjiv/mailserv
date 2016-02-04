class Forwarding
  
  include Mongoid::Document
  include Mongoid::Timestamps   
      
  belongs_to :domain
   
  field :source, type: String 
  field :destination, type: Array
     
     
end
