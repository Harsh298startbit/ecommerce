class OrdersController < ApplicationController
  before_action :require_login
  before_action :set_order, only: [:show, :checkout, :payment_intent]

  def index
    @orders = current_user.orders.recent.page(params[:page]).per_page(10)
  end

  def show
    unless @order.user_id == current_user.id
      redirect_to orders_path, alert: "You can only view your own orders."
    end
  end

  def new
    @cart = current_user.carts.find_by(id: session[:cart_id])
    
    if @cart.nil? || @cart.cart_items.empty?
      redirect_to root_path, alert: "Your cart is empty."
      return
    end

    @order = Order.new
    @total = @cart.cart_items.sum { |item| item.product_variant.price * item.quantity }
  end

  def create
    @cart = current_user.carts.find_by(id: session[:cart_id])
    
    if @cart.nil? || @cart.cart_items.empty?
      redirect_to root_path, alert: "Your cart is empty."
      return
    end

    @order = current_user.orders.build(order_params)
    
    # Calculate total amount
    total_amount = @cart.cart_items.sum { |item| item.product_variant.price * item.quantity }
    @order.total_amount = total_amount

    if @order.save
      # Create order items from cart items
      @cart.cart_items.each do |cart_item|
        @order.order_items.create!(
          product_id: cart_item.product_variant.product_id,
          product_variant_id: cart_item.product_variant_id,
          quantity: cart_item.quantity,
          price: cart_item.product_variant.price,
          product_name: cart_item.product.name,
          variant_name: cart_item.product_variant.value
        )
      end

      # Create Stripe Payment Intent
      begin
        payment_intent = Stripe::PaymentIntent.create({
          amount: (total_amount * 100).to_i, # Stripe expects amount in cents
          currency: 'inr',
          metadata: {
            order_id: @order.id,
            order_number: @order.order_number
          }
        })

        @order.update(stripe_payment_intent_id: payment_intent.id)
        
        redirect_to checkout_order_path(@order), notice: "Order created successfully. Please complete payment."
      rescue Stripe::StripeError => e
        @order.destroy
        redirect_to new_order_path, alert: "Payment processing error: #{e.message}"
      end
    else
      @total = total_amount
      render :new
    end
  end

  def checkout
    @order = current_user.orders.find_by(id: params[:id])
    
    unless @order
      redirect_to orders_path, alert: "Order not found."
      return
    end

    if @order.paid? || @order.completed?
      redirect_to order_path(@order), notice: "This order has already been paid."
      return
    end
  end

  def payment_intent
    unless @order
      render json: { error: "Order not found" }, status: :not_found
      return
    end

    unless @order.user_id == current_user.id
      render json: { error: "Unauthorized" }, status: :unauthorized
      return
    end

    begin
      payment_intent = Stripe::PaymentIntent.retrieve(@order.stripe_payment_intent_id)
      render json: { clientSecret: payment_intent.client_secret }
    rescue Stripe::StripeError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(
      :shipping_name, :shipping_address, :shipping_city, 
      :shipping_state, :shipping_zip, :shipping_country, :email, :phone
    )
  end

  def require_login
    unless logged_in?
      redirect_to login_path, alert: "Please log in to continue."
    end
  end
end
