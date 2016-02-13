class DomainsController < ApplicationController
  before_action :build_domain, only: [:index, :create]
  before_action :get_domain, only: [:update, :destroy, :show]

  def index
    @user = User.new
    @forwarding = Forwarding.new
    @domains = Domain.order(name: :asc)
  end

  def create
    flash[:notice] = 'Domain successfully created.' if @domain.save

    respond_to do |format|
      format.js { render 'domains/upsert' }
    end
  end

  def update
    flash[:notice] = 'Domain successfully updated.' if @domain.update(domain_params)

    respond_to do |format|
      format.js { render 'domains/upsert' }
    end
  end

  def show
    @users = @domain.users.to_a
    @forwardings = @domain.forwardings.to_a

    @user = @domain.users.build#User.new(domain: @domain)
    @forwarding = @domain.forwardings.build # Forwarding.new(domain: @domain)
  end

  def destroy
    @domain.destroy
    redirect_to domain_path, notice: 'Domain deleted successfully.'
  end

  private

  def domain_params
    params.fetch(:domain, {}).permit(:name, :allowed_quota, :max_allowed_quota)
  end

  def get_domain
    @domain = Domain.where(id: params[:id]).first
  end

  def build_domain
    @domain = Domain.new(domain_params)
  end
   
end
