class Forwarding
  
  include Mongoid::Document
  include Mongoid::Timestamps   
      
  belongs_to :domain
   
  field :source, type: String 
  field :destination, type: Array
     
  def json_presentation
    as_json(only: [:_id, :source, :destination, :domain_id])
  end
end
