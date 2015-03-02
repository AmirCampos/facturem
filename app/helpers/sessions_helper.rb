module SessionsHelper
  def log_in(issuer)
    session[:issuer_id] = issuer.id
  end

  def current_issuer
    @current_issuer ||= Issuer.find_by(id: session[:issuer_id])
  end

  def logged_in?
   !current_issuer.nil?
  end

   def log_out
    session.delete(:issuer_id)
    @current_issuer = nil
  end

end
