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
    
    if email.present?
      # You can add logic here to save to database or send to email service
      flash[:notice] = "Thank you for subscribing! You'll receive updates at #{email}"
    else
      flash[:alert] = "Please enter a valid email address"
    end
    
    redirect_back(fallback_location: root_path)
  end
end
