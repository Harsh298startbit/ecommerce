// Stripe checkout functionality
document.addEventListener('turbolinks:load', () => {
  const checkoutForm = document.getElementById('payment-form');
  
  if (checkoutForm && window.orderData) {
    initializeStripeCheckout();
  }
});

async function initializeStripeCheckout() {
  // Get Stripe publishable key from meta tag
  const stripeKey = document.querySelector('meta[name="stripe-publishable-key"]')?.content;
  
  if (!stripeKey) {
    console.error('Stripe publishable key not found');
    return;
  }

  const stripe = Stripe(stripeKey);
  
  // Fetch the payment intent client secret
  const response = await fetch(`/orders/${window.orderData.orderId}/payment_intent`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
    }
  });

  const { clientSecret } = await response.json();

  // Initialize Stripe Elements
  const elements = stripe.elements({ clientSecret });
  const paymentElement = elements.create('payment');
  paymentElement.mount('#payment-element');

  const form = document.getElementById('payment-form');
  const submitButton = document.getElementById('submit-button');
  const buttonText = document.getElementById('button-text');
  const spinner = document.getElementById('spinner');
  const messageContainer = document.getElementById('payment-message');

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    // Disable form submission while processing
    submitButton.disabled = true;
    buttonText.classList.add('hidden');
    spinner.classList.remove('hidden');

    const { error } = await stripe.confirmPayment({
      elements,
      confirmParams: {
        return_url: `${window.location.origin}/orders/${window.orderData.orderId}`,
      },
    });

    if (error) {
      // Show error message
      messageContainer.textContent = error.message;
      messageContainer.classList.remove('hidden');
      
      // Re-enable form
      submitButton.disabled = false;
      buttonText.classList.remove('hidden');
      spinner.classList.add('hidden');
    }
  });
}
