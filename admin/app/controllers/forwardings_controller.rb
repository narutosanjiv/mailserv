class ForwardingsController < ApplicationController

  before_action :get_domain

  before_action :build_forwarding, only: [:index, :create]
  before_action :get_forwarding, only: [:update, :destroy]

  def index
    @users = @domain.forwardings.order(source: :asc)
  end

  def create
    flash[:notice] = 'Forwarding successfully created.' if @forwarding.save

    respond_to do |format|
      format.js { render 'forwardings/upsert' }
    end
  end

  def update
    flash[:notice] = 'Forwarding successfully updated.' if @forwarding.update(forwarding_params)

    respond_to do |format|
      format.js { render 'administrators/upsert' }
    end
  end

  def destroy
    @forwarding.destroy
    redirect_to domain_forwardings_path(params[:domain_id]), notice: 'Forwarding deleted successfully.'
  end

  private

  def forwarding_params
    params.fetch(:forwarding, {}).permit(:source, :destination)
  end

  def get_forwarding
    @forwarding = @domain.forwardings.where(id: params[:id]).first
  end

  def build_get_forwarding
    @forwarding = @domain.forwardings.build(forwarding_params)
  end

  def get_domain
    @domain = Domain.find(params[:domain_id])
  end
end
