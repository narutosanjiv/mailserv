class SessionsController < ApplicationController
  skip_before_filter :require_login, :only => [:new, :create]

  def new
    @admin = SuperAdmin.new
    render layout: "login"
  end

  def create
    
    if @admin = login(params[:super_admin][:username], params[:super_admin][:password])
      redirect_back_or_to(:users, notice: 'Login successful')
    else
      @admin = SuperAdmin.new(username: params[:super_admin][:username])
      flash.now[:error] = 'Incorrect username/password.'
      render action: 'new', layout: "login"
    end
  end

  def destroy
    logout
    redirect_to(:users, notice: 'Logged out!')
  end
end
