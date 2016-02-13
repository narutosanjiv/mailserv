class UsersController < ApplicationController

  before_action :get_domain

  before_action :build_user, only: [:index, :create]
  before_action :get_user, only: [:update, :destroy]

  def index
    @users = @domain.users.order(name: :asc)
  end

  def create
    flash[:notice] = 'User successfully created.' if @user.save

    respond_to do |format|
      format.js { render 'users/upsert' }
    end
  end

  def update
    flash[:notice] = 'User successfully updated.' if @user.update(user_params)

    respond_to do |format|
      format.js { render 'users/upsert' }
    end
  end

  def destroy
    @user.destroy
    redirect_to domain_path(params[:domain_id]), notice: 'User deleted successfully.'
  end

  private

  def user_params
    params.fetch(:user, {}).permit(:name, :email, :password, :password_confirmation, :is_admin)
  end

  def get_administrators
  end

  def get_user
    @user = @domain.users.where(id: params[:id]).first
  end

  def build_user
    @user = @domain.users.build(user_params)
  end

  def get_domain
    @domain = Domain.find(params[:domain_id])
  end
end
