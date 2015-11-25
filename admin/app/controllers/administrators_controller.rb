class AdministratorsController < ApplicationController

  before_action :build_administrator, only: [:index, :create]
  before_action :get_administrator, only: [:update, :destroy]

  def index
    @administrators = Administrator.order(username: :asc)
  end

  def create
    flash[:notice] = 'Administrator successfully created.' if @administrator.save

    respond_to do |format|
      format.js { render 'administrators/upsert' }
    end
  end

  def update
    flash[:notice] = 'Administrator successfully updated.' if @administrator.update(administrator_params)

    respond_to do |format|
      format.js { render 'administrators/upsert' }
    end
  end

  def destroy
    @administrator.destroy
    redirect_to administrators_path, notice: 'Administrator deleted successfully.'
  end

  private

  def administrator_params
    params.fetch(:administrator, {}).permit(:username, :email, :password, :password_confirmation)
  end

  def get_administrators
  end

  def get_administrator
    @administrator = Administrator.where(id: params[:id]).first
  end

  def build_administrator
    @administrator = Administrator.new(administrator_params)
  end
end
