module SessionsHelper
  def log_in(issuer)
    session[:issuer_id] = issuer.id
  end

  def logged_in?
    !current_issuer.nil?
  end

  def log_out
    session.delete(:issuer_id)
    @current_issuer = nil
  end

  # code from: https://www.railstutorial.org/book/log_in_log_out#sec-remember_me

  # Remembers a issuer in a persistent session.
  def remember(issuer)
    issuer.remember
    # permanent = 20 years
    # cookies.permanent.signed[:issuer_id] = issuer.id
    # cookies.permanent[:remember_token] = issuer.remember_token
    cookies.signed[:issuer_id] = { value: issuer.id, expires: 15.days.from_now.utc }
    cookies[:remember_token] = { value: issuer.remember_token, expires: 15.days.from_now.utc }
  end

  # Returns the issuer corresponding to the remember token cookie.
  def current_issuer
    # IMPORTANT! assignation here with ONE =
    if (issuer_id = session[:issuer_id])
      @current_issuer ||= Issuer.find_by(id: issuer_id)
      # IMPORTANT! assignation here with ONE =
    elsif (issuer_id = cookies.signed[:issuer_id])
      issuer = Issuer.find_by(id: issuer_id)
      if issuer && issuer.authenticated?(cookies[:remember_token])
        log_in issuer
        @current_issuer = issuer
      end
    end
  end

  # Forgets a persistent session.
  def forget(issuer)
    issuer.forget
    cookies.delete(:issuer_id)
    cookies.delete(:remember_token)
  end

  # Logs out the current issuer.
  def log_out
    forget(current_issuer)
    session.delete(:issuer_id)
    @current_issuer = nil
  end

end
