class SessionsController < ApplicationController
  def new
  end

  def create
    issuer = Issuer.find_by(email: params[:session][:email].downcase)
    # TODO: authenticate
    #if issuer && issuer.authenticate(params[:session][:password])
    if issuer && issuer.password == params[:session][:password]
      flash.discard(:alert)
      log_in(issuer)
      redirect_to root_path
    else
      flash[:alert] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to login_path
  end
end
