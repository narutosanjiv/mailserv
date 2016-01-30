class Domain
  include Mongoid::Document
  
  field :allowed_quota, type: Integer
  field :max_allowed_quota, type: Integer 
  field :name, type: String 
  
  validates :name, uniqueness: true, presence: true
  validates_presence_of :max_allowed_quota, :allowed_quota
  validates_numericality_of :allowed_quota, :max_allowed_quota

  #less and equal to 5000mb
  validates_numericality_of :max_allowed_quota, less_than_or_equal_to: 5000, greater_than: 0

  def json_presentation
    as_json(only: [:_id, :name, :allowed_quota, :max_allowed_quota])
  end
end
