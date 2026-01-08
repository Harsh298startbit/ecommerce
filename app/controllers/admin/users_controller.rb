class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:edit, :update, :destroy, :toggle_admin]
  
  def index
    @users = User.order(created_at: :desc).page(params[:page]).per_page(20)
  end
  
  def edit
  end
  
  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User updated successfully."
    else
      render :edit
    end
  end
  
  def destroy
    if @user.id == current_user.id
      redirect_to admin_users_path, alert: "You cannot delete your own account."
      return
    end
    
    @user.destroy
    redirect_to admin_users_path, notice: "User deleted successfully."
  end
  
  def toggle_admin
    if @user.id == current_user.id
      render json: { error: "You cannot change your own admin status" }, status: :unprocessable_entity
      return
    end
    
    @user.update(is_admin: !@user.is_admin)
    render json: { 
      success: true, 
      is_admin: @user.is_admin,
      message: "User role updated to #{@user.is_admin ? 'Admin' : 'Customer'}"
    }
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def user_params
    params.require(:user).permit(:name, :email, :is_admin)
  end
end
