class Domain
  include Mongoid::Document
  
  has_many :users
  has_many :forwarding
  
  field :allowed_quota, type: Integer, default: 2000
  field :max_allowed_quota, type: Integer, default: 5000
  field :name, type: String 
  
  validates :name, uniqueness: true, presence: true
  validates_presence_of :max_allowed_quota, :allowed_quota
  validates_numericality_of :allowed_quota, :max_allowed_quota

  #less and equal to 5000mb
  validates_numericality_of :max_allowed_quota, less_than_or_equal_to: 5000, greater_than: 0

  def json_presentation
    as_json(only: [:_id, :name, :allowed_quota, :max_allowed_quota])
  end
  
  def user_count
    self.users.count
  end

  def forwarding_counts
    self.forwardings.count
  end

  def before_save 
    unless self.new_record?
      @old_name = self.name
    end 

  end

  def after_create
    logger.info "Creating directory /var/mailserv/mail/#{name}"
    logger.info %x{sudo mkdir -m 755 /var/mailserv/mail/#{name}}
  end

  def after_update
    if !File.exists?("/var/mailserv/mail/#{name}")
      %x{sudo mv /var/mailserv/mail/#{@oldname} /var/mailserv/mail/#{name}}
    end
  end

  def after_save
    #system("sudo /usr/local/bin/rake RAILS_ENV=production -f /var/mailserv/admin/Rakefile mailserver:configure:domains &") if Rails.env.production?
  end

end
