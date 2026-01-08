class Admin::OrdersController < Admin::BaseController
  before_action :set_order, only: [:show, :update]
  
  def index
    @orders = Order.includes(:user).order(created_at: :desc).page(params[:page]).per_page(20)
  end
  
  def show
    @order_items = @order.order_items.includes(:product, :product_variant)
  end
  
  def update
    if @order.update(order_params)
      redirect_to admin_order_path(@order), notice: "Order updated successfully."
    else
      redirect_to admin_order_path(@order), alert: "Failed to update order."
    end
  end
  
  private
  
  def set_order
    @order = Order.find(params[:id])
  end
  
  def order_params
    params.require(:order).permit(:status)
  end
end
