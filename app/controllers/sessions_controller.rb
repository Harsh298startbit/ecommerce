class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      # detect if user requested an admin login via the checkbox
      admin_requested = params[:admin_login].present? && params[:admin_login].to_s == '1'
      if admin_requested && !user.admin?
        @success = false
        @message = "Access denied: admin credentials required."
        respond_to do |format|
          format.html do
            flash.now[:alert] = @message
            render :new, status: :forbidden
          end
          format.js
        end
        return
      end
      session[:user_id] = user.id
      @success = true
      @message = "Logged in successfully!"
      # Explicit post-login redirection:
      # - admins -> admin dashboard
      # - if a return path was stored in session -> go there
      # - otherwise -> root path (storefront)
      if user.admin?
        redirect_path = admin_root_path
        Rails.logger.info "User \#{user.id} is admin; redirecting to admin dashboard"
      elsif session[:return_to].present?
        redirect_path = session.delete(:return_to)
      else
        redirect_path = root_path
      end

      # expose redirect path to views (including JS response)
      @redirect_path = redirect_path

      respond_to do |format|
        format.html { redirect_to redirect_path, notice: @message }
        format.js
      end
    else
      @success = false
      @message = "Invalid email or password"
      
      respond_to do |format|
        format.html do
          flash.now[:alert] = @message
          render :new, status: :unprocessable_entity
        end
        format.js
      end
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Logged out successfully!"
  end
end
