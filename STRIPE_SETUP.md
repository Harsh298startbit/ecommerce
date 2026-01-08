# Stripe Payment Gateway Integration Guide

This document explains how to configure and use the Stripe payment gateway integration in your e-commerce application.

## Overview

The payment system has been fully integrated with:
- Order creation and management
- Stripe payment processing
- Webhook handling for payment events
- Secure checkout flow

## Setup Instructions

### 1. Get Your Stripe API Keys

1. Sign up for a Stripe account at https://stripe.com
2. Go to Developers > API keys
3. Copy your **Publishable key** and **Secret key** (use test keys for development)

### 2. Configure Stripe Credentials

You can configure Stripe in two ways:

#### Option A: Using Rails Credentials (Recommended)

```bash
EDITOR="code --wait" rails credentials:edit
```

Add the following to your credentials file:

```yaml
stripe:
  publishable_key: pk_test_your_publishable_key_here
  secret_key: sk_test_your_secret_key_here
  webhook_secret: whsec_your_webhook_secret_here
```

#### Option B: Using Environment Variables

Create a `.env` file in your project root:

```bash
STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key_here
STRIPE_SECRET_KEY=sk_test_your_secret_key_here
```

**Note:** The `.env` file should be added to `.gitignore` to keep your keys secure.

### 3. Test the Integration

#### Test Card Numbers

Use these test cards in development:

- **Success**: 4242 4242 4242 4242
- **Decline**: 4000 0000 0000 0002
- **3D Secure**: 4000 0025 0000 3155

Use any future expiry date, any 3-digit CVC, and any ZIP code.

### 4. Webhook Setup (Optional for Development)

Webhooks allow Stripe to notify your application about payment events.

#### For Development (Using Stripe CLI):

1. Install Stripe CLI: https://stripe.com/docs/stripe-cli
2. Run in a terminal:
   ```bash
   stripe login
   stripe listen --forward-to localhost:3000/webhooks/stripe
   ```
3. Copy the webhook signing secret and add it to your credentials

#### For Production:

1. Go to Stripe Dashboard > Developers > Webhooks
2. Add endpoint: `https://yourdomain.com/webhooks/stripe`
3. Select events: `payment_intent.succeeded`, `payment_intent.payment_failed`
4. Copy the webhook signing secret to your production credentials

## How It Works

### 1. Checkout Flow

1. User adds items to cart
2. User clicks "Proceed to Checkout" in cart
3. User fills in shipping information on checkout page
4. Order is created with status "pending"
5. User is redirected to payment page
6. User enters card details (handled securely by Stripe)
7. Payment is processed
8. On success, order status updates to "paid" and cart is cleared

### 2. Order Management

Users can:
- View all their orders at `/orders`
- View order details at `/orders/:id`
- Complete payment for pending orders

### 3. Payment Processing

- All card data is handled directly by Stripe (PCI compliant)
- Your server never touches raw card numbers
- Payment intents are used for secure, multi-step payments
- 3D Secure authentication is automatically handled

## Database Schema

### Orders Table
- `order_number` - Unique order identifier
- `user_id` - Foreign key to users
- `total_amount` - Order total in decimal
- `status` - pending, paid, completed, cancelled, failed
- `stripe_payment_intent_id` - Stripe payment intent ID
- `shipping_name`, `shipping_address`, etc. - Shipping details

### Order Items Table
- `order_id` - Foreign key to orders
- `product_id` - Foreign key to products
- `product_variant_id` - Foreign key to product_variants
- `quantity` - Item quantity
- `price` - Price at time of purchase
- `product_name`, `variant_name` - Snapshot of product details

## Security Features

✅ CSRF protection enabled
✅ Card data never touches your server
✅ Webhook signature verification
✅ User authentication required for all order actions
✅ HTTPS enforced in production

## Testing Checklist

- [ ] Can create an order from cart
- [ ] Can enter shipping information
- [ ] Payment form loads correctly
- [ ] Can complete payment with test card
- [ ] Order status updates to "paid" after payment
- [ ] Cart is cleared after successful payment
- [ ] Can view order history
- [ ] Can view individual order details
- [ ] Failed payments are handled gracefully
- [ ] Webhook events are processed correctly

## Important Notes

### Development
- Use Stripe test keys (starts with `pk_test_` and `sk_test_`)
- Use test card numbers only
- Webhook secret is optional (you can test without it)

### Production
- Switch to live keys (starts with `pk_live_` and `sk_live_`)
- Set up webhook endpoint
- Ensure HTTPS is enabled
- Test thoroughly before going live

## Troubleshooting

### "Stripe publishable key not found"
- Check that credentials are configured correctly
- Verify the initializer at `config/initializers/stripe.rb`
- Restart your Rails server

### Payment form doesn't load
- Check browser console for JavaScript errors
- Verify Stripe.js is loaded in layout
- Check that stripe_checkout.js is included in application pack

### Webhook signature verification fails
- Make sure webhook secret is correct in credentials
- Use Stripe CLI for local testing
- Check that endpoint URL matches in Stripe dashboard

## Support

For Stripe-specific issues:
- Stripe Documentation: https://stripe.com/docs
- Stripe Support: https://support.stripe.com

## Additional Features You Can Add

1. **Email Notifications**: Send order confirmation emails
2. **Order Tracking**: Add tracking numbers and shipment status
3. **Refunds**: Implement refund processing
4. **Subscription Support**: Add recurring payments
5. **Multiple Payment Methods**: Add PayPal, Apple Pay, Google Pay
6. **Invoice Generation**: Create PDF invoices
7. **Order Export**: Export orders to CSV for accounting

---

**Note:** Always keep your Stripe secret keys secure and never commit them to version control!
