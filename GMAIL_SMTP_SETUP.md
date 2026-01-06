# Gmail SMTP Setup Guide for E-commerce Project

## ✅ Completed Configuration

All necessary files have been configured for Gmail SMTP integration. Follow the steps below to complete the setup.

---

## 📋 Setup Steps

### 1. Install Dependencies
```bash
bundle install
```

### 2. Create Gmail App Password

1. Go to your Google Account: https://myaccount.google.com/
2. Navigate to **Security**
3. Enable **2-Step Verification** (required)
4. Search for **App passwords** in the search bar
5. Select:
   - App: **Mail**
   - Device: **Other (Custom name)** → Enter "Rails E-commerce"
6. Google will generate a **16-character password** (e.g., `abcd efgh ijkl mnop`)
7. **Save this password securely** - you'll need it in the next step

### 3. Create .env File

Create a `.env` file in the project root:

```bash
cp .env.example .env
```

Edit `.env` and add your credentials:

```env
GMAIL_USERNAME=youremail@gmail.com
GMAIL_PASSWORD=your-16-char-app-password
MAILER_HOST=localhost:3000
```

**Important:** 
- Use the 16-character app password, NOT your regular Gmail password
- Remove spaces from the app password (e.g., `abcdefghijklmnop`)
- Never commit `.env` to git (it's already in .gitignore)

### 4. Production Environment Variables

For production, set these environment variables on your hosting platform:

```
GMAIL_USERNAME=youremail@gmail.com
GMAIL_PASSWORD=your-16-char-app-password
MAILER_HOST=yourdomain.com
```

**Hosting Platform Examples:**
- **Heroku:** `heroku config:set GMAIL_USERNAME=youremail@gmail.com`
- **Railway:** Add in project settings → Variables
- **Render:** Add in Dashboard → Environment

---

## 📧 Usage Examples

### In Controllers

#### Send Password Reset Email
```ruby
# In your sessions controller or password reset controller
def forgot_password
  user = User.find_by(email: params[:email])
  if user
    reset_token = SecureRandom.urlsafe_base64
    # Store reset_token in database with expiry
    UserMailer.password_reset(user, reset_token).deliver_now
    flash[:success] = "Password reset email sent!"
  end
end
```

#### Send Welcome Email on Registration
```ruby
# In users_controller.rb
def create
  @user = User.new(user_params)
  if @user.save
    UserMailer.welcome_email(@user).deliver_now
    redirect_to root_path, notice: "Welcome! Check your email."
  end
end
```

#### Send Newsletter Subscription Confirmation
```ruby
# In your newsletter/subscription controller
def subscribe
  email = params[:email]
  # Save email to newsletter list
  UserMailer.subscription_confirmation(email).deliver_now
  redirect_to root_path, notice: "Thanks for subscribing!"
end
```

### In Rails Console (for testing)

```ruby
# Test password reset email
user = User.first
UserMailer.password_reset(user, "sample-token-123").deliver_now

# Test welcome email
UserMailer.welcome_email(user).deliver_now

# Test subscription confirmation
UserMailer.subscription_confirmation("test@example.com").deliver_now
```

---

## 🧪 Testing in Development

1. Start your Rails server:
```bash
rails server
```

2. Open Rails console:
```bash
rails console
```

3. Send a test email:
```ruby
UserMailer.subscription_confirmation("your-test-email@gmail.com").deliver_now
```

4. Check your email inbox!

---

## 📁 Files Created/Modified

### Configuration Files
- ✅ [config/environments/development.rb](config/environments/development.rb) - Development SMTP settings
- ✅ [config/environments/production.rb](config/environments/production.rb) - Production SMTP settings
- ✅ [.gitignore](.gitignore) - Added .env files
- ✅ [.env.example](.env.example) - Environment variables template
- ✅ [Gemfile](Gemfile) - Added dotenv-rails gem

### Mailer Files
- ✅ [app/mailers/application_mailer.rb](app/mailers/application_mailer.rb) - Base mailer
- ✅ [app/mailers/user_mailer.rb](app/mailers/user_mailer.rb) - User mailer with 3 methods

### Email Templates (HTML & Text versions)
- ✅ Password Reset: [password_reset.html.erb](app/views/user_mailer/password_reset.html.erb) & [password_reset.text.erb](app/views/user_mailer/password_reset.text.erb)
- ✅ Welcome Email: [welcome_email.html.erb](app/views/user_mailer/welcome_email.html.erb) & [welcome_email.text.erb](app/views/user_mailer/welcome_email.text.erb)
- ✅ Subscription: [subscription_confirmation.html.erb](app/views/user_mailer/subscription_confirmation.html.erb) & [subscription_confirmation.text.erb](app/views/user_mailer/subscription_confirmation.text.erb)

---

## 🚨 Common Issues & Solutions

### Issue: "Username and Password not accepted"
**Solution:** 
- Make sure you're using the App Password, not your regular Gmail password
- Ensure 2-Step Verification is enabled
- Remove any spaces from the app password

### Issue: "Net::SMTPAuthenticationError"
**Solution:**
- Double-check your GMAIL_USERNAME (must be full email)
- Verify the app password is correct (16 characters)
- Try generating a new app password

### Issue: Emails not sending in development
**Solution:**
- Check your .env file exists and has correct values
- Restart your Rails server after creating .env
- Check Rails logs: `tail -f log/development.log`

### Issue: "Less secure app access" error
**Solution:** 
- This is the OLD method - you should use App Passwords instead
- Google no longer supports "less secure apps" as of May 2022

---

## 🎯 Next Steps

1. ✅ Run `bundle install`
2. ✅ Create your `.env` file with Gmail credentials
3. ✅ Test sending an email in Rails console
4. ✅ Integrate mailers into your controllers
5. ✅ Customize email templates with your branding
6. ✅ Set up production environment variables on your hosting platform

---

## 📚 Additional Resources

- [Action Mailer Basics](https://guides.rubyonrails.org/action_mailer_basics.html)
- [Gmail SMTP Settings](https://support.google.com/mail/answer/7126229)
- [Google App Passwords](https://support.google.com/accounts/answer/185833)

---

## 💡 Pro Tips

1. **Use deliver_later for production:** For better performance, use `deliver_later` instead of `deliver_now` with a background job processor like Sidekiq
   
2. **Add email previews:** Create email previews for development:
   ```ruby
   # test/mailers/previews/user_mailer_preview.rb
   class UserMailerPreview < ActionMailer::Preview
     def password_reset
       UserMailer.password_reset(User.first, "sample-token")
     end
   end
   ```
   Then visit: http://localhost:3000/rails/mailers

3. **Monitor email sending:** Consider using services like SendGrid, Mailgun, or AWS SES for production for better deliverability and analytics

4. **Gmail Sending Limits:** 
   - Free Gmail accounts: 500 emails/day
   - Google Workspace: 2000 emails/day
   - For higher volume, consider dedicated email services

---

**Setup completed! 🎉** Your e-commerce project is now configured for Gmail SMTP.
