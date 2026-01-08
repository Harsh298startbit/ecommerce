class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :current_cart

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in to access this page"
      redirect_to login_path
    end
  end
  
  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end

  def current_cart
    if logged_in?
      if session[:cart_id]
        @current_cart = current_user.carts.find_by(id: session[:cart_id])
        return @current_cart if @current_cart
      end
      
      # Create new cart if none exists
      @current_cart = current_user.carts.create!
      session[:cart_id] = @current_cart.id
      @current_cart
    else
      nil
    end
  end
end
