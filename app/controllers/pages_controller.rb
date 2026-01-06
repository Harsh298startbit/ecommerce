class PagesController < ApplicationController
  def about
  end

  def blog
  end

  def contact
  end

  def contact_submit
    # Handle contact form submission
    name = params[:name]
    email = params[:email]
    subject = params[:subject]
    message = params[:message]
    
    if name.present? && email.present? && message.present?
      # You can add logic here to send email or save to database
      flash[:notice] = "Thank you #{name}! Your message has been sent successfully."
    else
      flash[:alert] = "Please fill in all required fields"
    end
    
    redirect_to pages_contact_path
  end

  def subscribe
    # Handle newsletter subscription
    email = params[:email]
    
    if email.present? && email.match?(URI::MailTo::EMAIL_REGEXP)
      # Send subscription confirmation email
      UserMailer.subscription_confirmation(email).deliver_now
      flash[:notice] = "Thank you for subscribing! Check your email for confirmation."
    else
      flash[:alert] = "Please enter a valid email address"
    end
    
    redirect_back(fallback_location: root_path)
  end
end
