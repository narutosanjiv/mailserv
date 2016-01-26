class DomainsController < ApplicationController
  before_action :build_domain, only: [:index, :create]
  before_action :get_domain, only: [:update, :destroy]

  def index
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

  def destroy
    @domain.destroy
    redirect_to domains_path, notice: 'Domain deleted successfully.'
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
