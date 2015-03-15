class SessionsController < ApplicationController
  def new
  end

  # code from: https://www.railstutorial.org/book/log_in_log_out#sec-remember_me
  def create
    issuer = Issuer.find_by(email: params[:session][:email].downcase)
    if issuer && issuer.authenticate(params[:session][:password])
      flash.discard(:alert)
      log_in(issuer)
      if params[:session][:remember_me] == '1'
        remember(issuer)
      else
        forget(issuer)
      end
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
