class SessionsController < ApplicationController
  skip_before_filter :require_login, :only => [:new, :create]

  layout 'login'

  def new
    @admin = Administrator.new
  end

  def create
    if login(session_params[:username], session_params[:password])
      redirect_back_or_to(:root, notice: 'Login successful')
    else
      @admin = Administrator.new(username: session_params[:username])
      flash.now[:error] = 'Incorrect username/password.'
      render action: 'new'
    end
  end

  def destroy
    logout
    redirect_to(:new_session, notice: 'Logged out!')
  end

  private

  def session_params
    params.fetch(:super_admin).permit(:username, :password)
  end
end
