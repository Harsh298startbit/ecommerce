class PaymentsController < ApplicationController
  before_action :require_login
  skip_before_action :verify_authenticity_token, only: [:webhook]

  def create
    order = current_user.orders.find(params[:order_id])

    begin
      payment_intent = Stripe::PaymentIntent.retrieve(order.stripe_payment_intent_id)
      
      if payment_intent.status == 'succeeded'
        order.update(status: 'paid')
        
        # Send payment receipt email
        UserMailer.payment_receipt(order).deliver_later
        
        # Clear the cart after successful payment
        cart = current_user.carts.find_by(id: session[:cart_id])
        if cart
          cart.cart_items.destroy_all
          session.delete(:cart_id)
        end

        render json: { 
          status: 'success', 
          redirect_url: order_path(order),
          message: 'Payment successful!' 
        }
      else
        render json: { 
          status: 'error', 
          message: 'Payment not completed' 
        }, status: :unprocessable_entity
      end
    rescue Stripe::StripeError => e
      render json: { 
        status: 'error', 
        message: e.message 
      }, status: :unprocessable_entity
    end
  end

  def webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      render json: { error: 'Invalid payload' }, status: :bad_request
      return
    rescue Stripe::SignatureVerificationError => e
      render json: { error: 'Invalid signature' }, status: :bad_request
      return
    end

    # Handle the event
    case event.type
    when 'payment_intent.succeeded'
      payment_intent = event.data.object
      handle_payment_success(payment_intent)
    when 'payment_intent.payment_failed'
      payment_intent = event.data.object
      handle_payment_failure(payment_intent)
    end

    render json: { message: 'success' }
  end

  private

  def handle_payment_success(payment_intent)
    order = Order.find_by(stripe_payment_intent_id: payment_intent.id)
    if order && order.pending?
      order.update(status: 'paid')
      # Send order confirmation and payment receipt emails
      UserMailer.order_confirmation(order).deliver_later
      UserMailer.payment_receipt(order).deliver_later
    end
  end

  def handle_payment_failure(payment_intent)
    order = Order.find_by(stripe_payment_intent_id: payment_intent.id)
    if order
      order.update(status: 'failed')
    end
  end

  def require_login
    unless logged_in?
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end
