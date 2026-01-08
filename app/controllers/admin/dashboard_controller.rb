class Admin::DashboardController < Admin::BaseController
  def index
    @total_users = User.count
    @total_orders = Order.count
    @total_products = Product.count
    @recent_orders = Order.order(created_at: :desc).limit(10)
    @total_revenue = Order.where(status: ['paid', 'completed']).sum(:total_amount)
  end
end
