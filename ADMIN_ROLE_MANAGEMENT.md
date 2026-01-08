# Admin Role Management System

## Overview
This project now has a **boolean-based role management system** where users can be either **Admin** or **Customer**.

## Database Structure
- **Field**: `is_admin` (boolean)
- **Default**: `false` (all new users are customers by default)
- **Values**:
  - `true` = Admin user
  - `false` = Customer user

## User Model Methods
```ruby
user.admin?     # Returns true if user is admin
user.customer?  # Returns true if user is customer
```

## How to Access Admin Panel from Browser

### Option 1: Login as Admin User (Recommended for Initial Setup)

1. **Login with pre-seeded admin account**:
   - Email: `admin@example.com`
   - Password: `admin123`

2. **Access admin dashboard**:
   - After login, click on your name in the navigation
   - You'll see admin-specific menu items:
     - **Admin Dashboard** (red colored link)
     - Manage Users
     - Manage Products
     - Manage Orders

3. **Direct URL Access**:
   - Admin Dashboard: `http://localhost:3000/admin`
   - User Management: `http://localhost:3000/admin/users`
   - Product Management: `http://localhost:3000/admin/products`
   - Order Management: `http://localhost:3000/admin/orders`

### Option 2: Manage User Roles from Admin Panel (Best for Production)

Once logged in as admin:

1. **Navigate to User Management**:
   - Click on "Manage Users" in the dropdown menu
   - Or visit: `http://localhost:3000/admin/users`

2. **Toggle User Roles**:
   - You'll see a list of all users
   - Each user has a "Toggle Role" button
   - Click it to switch between Admin and Customer
   - The badge will update in real-time via AJAX
   - You cannot change your own role (security feature)

3. **Visual Indicators**:
   - Admin users: Green badge with "Admin"
   - Customer users: Gray badge with "Customer"
   - Your own account: "Admin (You)" - cannot be modified

### Option 3: Using Rails Console (For Development/Testing)

```ruby
# Make an existing user an admin
rails console
user = User.find_by(email: "someone@example.com")
user.update(is_admin: true)

# Create a new admin user
User.create!(
  name: "New Admin",
  email: "newadmin@example.com",
  password: "password123",
  password_confirmation: "password123",
  is_admin: true
)

# Remove admin privileges
user.update(is_admin: false)
```

### Option 4: Database Seed File (For Initial Setup)

The seed file already includes admin user creation. Run:
```bash
rake db:seed
```

This creates:
- Admin: `admin@example.com` / `admin123`
- Customer: `customer@example.com` / `customer123`

## Admin Capabilities

### 1. Dashboard (`/admin`)
- View total users, orders, products
- See total revenue
- View recent orders
- Quick action buttons

### 2. User Management (`/admin/users`)
- View all users in a paginated list
- See user roles (Admin/Customer)
- Toggle admin status with one click
- Delete users (except yourself)
- Pagination support for large user bases

### 3. Product Management (`/admin/products`)
- View all products
- Create new products
- Edit existing products
- Delete products
- See product images, collections, categories
- Filter and search products

### 4. Order Management (`/admin/orders`)
- View all customer orders
- See order details (items, shipping, customer info)
- Update order status (pending → paid → completed)
- View order history
- Track revenue

## Security Features

1. **Authorization**:
   - All admin routes protected by `require_admin` before_action
   - Non-admin users redirected to homepage with error message
   - Cannot access admin panel without admin role

2. **Self-Protection**:
   - Admins cannot delete themselves
   - Admins cannot change their own role
   - Prevents accidental lockout

3. **Helper Methods**:
   ```ruby
   current_user.admin?     # Check if admin
   require_admin          # Redirect if not admin
   ```

## Navigation Updates

The main navigation menu now shows admin links conditionally:
- **Regular users**: See Home, Shop, About, Blog, Contact, My Orders, Wishlist, Cart
- **Admin users**: All of the above PLUS:
  - Admin Dashboard (highlighted in red)
  - Manage Users
  - Manage Products
  - Manage Orders

## Testing the System

1. **Test Customer Access**:
   - Login with `customer@example.com` / `customer123`
   - Try accessing `/admin` - should be redirected with error
   - Verify no admin links in navigation

2. **Test Admin Access**:
   - Login with `admin@example.com` / `admin123`
   - Access `/admin` - should see dashboard
   - Verify admin links appear in navigation
   - Test role toggle on another user

3. **Test Role Toggle**:
   - Login as admin
   - Go to User Management
   - Click "Toggle Role" on customer account
   - Verify badge updates from "Customer" to "Admin"
   - Logout and login as that user
   - Verify they now have admin access

## Production Recommendations

1. **Change Default Passwords**:
   ```ruby
   admin = User.find_by(email: "admin@example.com")
   admin.update(password: "your-secure-password", password_confirmation: "your-secure-password")
   ```

2. **Use Environment Variables** for admin emails:
   ```ruby
   # In seeds.rb
   admin_email = ENV['ADMIN_EMAIL'] || 'admin@example.com'
   ```

3. **Add Email Confirmation** before allowing role changes

4. **Add Audit Logging** to track role changes:
   ```ruby
   # Log who changed roles and when
   AdminLog.create(
     admin_id: current_user.id,
     action: "role_changed",
     target_user_id: user.id,
     details: "Changed to #{user.is_admin ? 'Admin' : 'Customer'}"
   )
   ```

## Troubleshooting

**Problem**: "Access denied" when trying to access admin panel
- **Solution**: Make sure you're logged in and your account has `is_admin: true`

**Problem**: Can't see admin links in navigation
- **Solution**: Check `current_user.admin?` returns true. Run `rake db:seed` to create admin user.

**Problem**: Toggle button doesn't work
- **Solution**: Check browser console for JavaScript errors. Ensure CSRF token is present.

**Problem**: Migration not applied
- **Solution**: Run `rake db:migrate` to add the `is_admin` column.

## Files Modified

### Controllers:
- `app/controllers/application_controller.rb` - Added `require_admin` helper
- `app/controllers/admin/base_controller.rb` - Base admin controller
- `app/controllers/admin/dashboard_controller.rb` - Admin dashboard
- `app/controllers/admin/users_controller.rb` - User management with role toggle
- `app/controllers/admin/products_controller.rb` - Product CRUD
- `app/controllers/admin/orders_controller.rb` - Order management

### Models:
- `app/models/user.rb` - Added `admin?` and `customer?` methods

### Views:
- `app/views/admin/dashboard/index.html.erb` - Dashboard with statistics
- `app/views/admin/users/index.html.erb` - User management with AJAX toggle
- `app/views/admin/products/index.html.erb` - Product listing
- `app/views/admin/orders/index.html.erb` - Order listing
- `app/views/admin/orders/show.html.erb` - Order details
- `app/views/shared/_navigation.html.erb` - Added admin menu items

### Routes:
- `config/routes.rb` - Added admin namespace with all routes

### Database:
- `db/migrate/..._add_is_admin_to_users.rb` - Added boolean column
- `db/seeds.rb` - Creates admin and customer users
