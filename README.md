# ODT Auction Platform

A modern, full-featured auction platform built with Ruby on Rails 8.1. This application provides a complete solution for managing products, users, and auctions with role-based access control, public browsing capabilities, and an intuitive admin interface.

## 🎯 Overview

ODT Auction Platform is a web-based auction system that allows users to:
- Browse and search products without registration
- Register and manage their account
- Create and list products for auction
- Administer users and products through a dedicated admin panel

The platform features a clean, modern UI inspired by Coinbase's design system, with responsive layouts and efficient pagination.

## ✨ Features

### User Management
- **User Registration**: Secure signup with name, surname, email, and password
- **Authentication**: Session-based login/logout with bcrypt password hashing
- **User Status Management**: Three-tier status system:
  - `waiting_for_approve`: New users awaiting admin approval
  - `active`: Approved users who can create products
  - `inactive`: Deactivated users
- **Role-Based Access**: Admin and regular user roles with appropriate permissions

### Product Management
- **Product Creation**: Users can create products with:
  - Name and description
  - Open price (starting bid)
  - Price per bid (minimum increment)
- **Product Listing**: View all products with pagination (8 items per page)
- **Product Search**: Search products by name or description
- **Product Sorting**: Sort by:
  - Newest first (default)
  - Price: Low to High
  - Price: High to Low
- **Product Caching**: Fragment caching for improved performance

### Public Area
- **No Login Required**: Browse products without registration
- **Product Details**: View detailed product information
- **Search & Filter**: Full search and sorting capabilities
- **Responsive Design**: Mobile-friendly interface

### Admin Features
- **Admin Dashboard**: Overview of platform statistics
- **User Management**: 
  - View all users (excluding current admin)
  - Filter by status (waiting, active, inactive)
  - Approve, activate, or deactivate users
- **User Statistics**: Counts by status

### Performance & UX
- **Pagination**: Efficient pagination with 8 items per page
- **Fragment Caching**: Cached product cards for faster loading
- **Search Persistence**: Search and sort parameters preserved across pagination
- **Navigation**: Consistent navigation across all public pages

## 🛠 Technology Stack

### Backend
- **Ruby**: 3.3.5
- **Rails**: 8.1.1
- **Database**: SQLite3
- **Server**: Puma 5.0+

### Key Gems
- `bcrypt` (~> 3.1.7) - Password hashing
- `pagy` - Fast, lightweight pagination
- `turbo-rails` - SPA-like page acceleration
- `stimulus-rails` - Modest JavaScript framework
- `solid_cache` - Database-backed cache store
- `solid_queue` - Database-backed job queue
- `solid_cable` - Database-backed Action Cable adapter

### Frontend
- **CSS**: Custom design system with CSS variables
- **JavaScript**: Import maps with ESM
- **Assets**: Propshaft asset pipeline
- **Icons**: SVG icons throughout the interface

## 📋 Prerequisites

Before you begin, ensure you have the following installed:
- Ruby 3.3.5 or higher
- RubyGems
- Bundler
- SQLite3
- Node.js (for asset compilation)

## 🚀 Getting Started

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd product-onboarding
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Set up the database**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. **Start the server**
   ```bash
   rails server
   ```

5. **Access the application**
   - Open your browser and navigate to `http://localhost:3000`

### Default Credentials

After running `rails db:seed`, you'll have:

**Admin User:**
- Email: `admin@example.com`
- Password: `admin123`

**Sample User:**
- Email: `seller@example.com`
- Password: `seller123`

## 📁 Project Structure

```
product-onboarding/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb      # Base controller with auth helpers
│   │   ├── concerns/
│   │   │   └── pagy_backend.rb           # Pagy pagination backend
│   │   ├── admin_controller.rb            # Admin dashboard
│   │   ├── admin/
│   │   │   └── users_controller.rb        # User management
│   │   ├── public_controller.rb          # Public product browsing
│   │   ├── products_controller.rb         # Product CRUD
│   │   ├── registrations_controller.rb    # User registration
│   │   ├── sessions_controller.rb         # Login/logout
│   │   └── home_controller.rb            # User dashboard
│   ├── models/
│   │   ├── user.rb                        # User model with status enum
│   │   └── product.rb                     # Product model
│   ├── views/
│   │   ├── layouts/
│   │   │   └── application.html.erb        # Main layout with navigation
│   │   ├── public/
│   │   │   ├── index.html.erb            # Public product list
│   │   │   ├── show.html.erb             # Product detail page
│   │   │   └── _product_card.html.erb    # Product card partial (cached)
│   │   ├── admin/
│   │   │   ├── dashboard.html.erb        # Admin dashboard
│   │   │   └── users/
│   │   │       └── index.html.erb        # User management
│   │   └── ...                           # Other views
│   └── helpers/
│       ├── application_helper.rb         # Application helpers
│       └── pagy_frontend.rb              # Pagy pagination frontend
├── config/
│   ├── routes.rb                         # Application routes
│   ├── initializers/
│   │   └── pagy.rb                       # Pagy configuration
│   └── ...                               # Other config files
├── db/
│   ├── migrate/                          # Database migrations
│   ├── schema.rb                         # Database schema
│   └── seeds.rb                          # Seed data
└── public/                               # Static assets
    ├── icon.svg                          # Favicon (SVG)
    └── icon.png                          # Favicon (PNG)
```

## 🗺 Routes Overview

### Public Routes
- `GET /` - Public product listing (root path)
- `GET /public/products/:id` - Public product detail page

### Authentication Routes
- `GET /signup` - User registration form
- `POST /signup` - Create new user
- `GET /registration/completed` - Registration success page
- `GET /login` - Login form
- `POST /login` - Authenticate user
- `DELETE /logout` - Logout user

### User Routes
- `GET /home` - User dashboard

### Product Routes
- `GET /products` - List all products (requires login)
- `GET /products/new` - Create new product form
- `POST /products` - Create product
- `GET /products/:id` - Show product details

### Admin Routes
- `GET /admin` or `GET /admin/dashboard` - Admin dashboard
- `GET /admin/users` - User management
- `PATCH /admin/users/:id/approve` - Approve user
- `PATCH /admin/users/:id/activate` - Activate user
- `PATCH /admin/users/:id/deactivate` - Deactivate user

## 🗄 Database Schema

### Users Table
```ruby
create_table "users" do |t|
  t.string "name", null: false
  t.string "surname", null: false
  t.string "email", null: false, unique: true
  t.string "password_digest", null: false
  t.boolean "admin", default: false, null: false
  t.integer "status", default: 0, null: false  # 0=waiting, 1=active, 2=inactive
  t.timestamps
end
```

### Products Table
```ruby
create_table "products" do |t|
  t.string "name", null: false
  t.text "description", null: false
  t.decimal "open_price", precision: 10, scale: 2, null: false
  t.decimal "price_per_bid", precision: 10, scale: 2, null: false
  t.integer "user_id", null: false
  t.timestamps
end
```

### Relationships
- `User` has_many `:products`
- `Product` belongs_to `:user`

## 📖 Usage Guide

### For Regular Users

1. **Registration**
   - Visit `/signup`
   - Fill in name, surname, email, and password
   - Submit the form
   - Wait for admin approval (status: `waiting_for_approve`)

2. **Login**
   - Visit `/login`
   - Enter email and password
   - Upon successful login, you'll be redirected to the home page

3. **Create Products**
   - After admin approval, log in and navigate to your dashboard
   - Click "Create Product"
   - Fill in product details (name, description, open price, price per bid)
   - Submit to create the product

4. **Browse Products**
   - Visit the root path `/` to see all products
   - Use the search bar to find specific products
   - Sort by price or date
   - Navigate through pages using pagination

### For Administrators

1. **Access Admin Panel**
   - Log in with admin credentials
   - Click "Admin Panel" in the navigation

2. **Manage Users**
   - Navigate to "Users" menu
   - View users filtered by status
   - Approve waiting users
   - Activate or deactivate users as needed

3. **View Statistics**
   - Check the admin dashboard for user counts
   - Monitor platform activity

### For Public Visitors

- Browse all products without registration
- Search and filter products
- View product details
- No login required for browsing

## 🔧 Development

### Running Tests
```bash
rails test
```

### Code Style
The project uses RuboCop with Rails Omakase configuration:
```bash
bundle exec rubocop
```

### Security Audits
```bash
bundle exec brakeman
bundle exec bundler-audit
```

### Database Console
```bash
rails dbconsole
```

### Rails Console
```bash
rails console
```

## 🐳 Docker Support

The project includes a `Dockerfile` for containerized deployment. See the Dockerfile for details on building and running the application in a container.

## 🚢 Deployment

### Production Considerations

1. **Database**: Consider migrating from SQLite3 to PostgreSQL or MySQL for production
2. **Cache Store**: Uses `solid_cache` (database-backed) - suitable for production
3. **Asset Pipeline**: Uses Propshaft - ensure assets are precompiled
4. **Environment Variables**: Set appropriate environment variables for production
5. **SSL**: Enable SSL/TLS for secure connections
6. **Secrets**: Use Rails credentials for sensitive configuration

### Kamal Deployment

The project includes Kamal configuration for easy deployment. See `config/deploy.yml` for deployment settings.

## 📝 Key Features Explained

### User Status System
Users go through three states:
1. **waiting_for_approve**: Initial state after registration
2. **active**: Approved by admin, can create products
3. **inactive**: Deactivated by admin

### Pagination
- Uses Pagy gem for efficient pagination
- 8 items per page
- Preserves search and sort parameters
- Custom pagination controls matching the design system

### Caching
- Fragment caching for product cards
- Cache keys include product `updated_at` timestamp
- Automatic cache invalidation when products are updated

### Search & Sort
- Full-text search across product names and descriptions
- Multiple sorting options
- Parameters preserved in URLs for sharing

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

[Specify your license here]

## 👥 Authors

[Add author information]

## 🙏 Acknowledgments

- Design inspiration from Coinbase
- Built with Ruby on Rails 8.1
- Uses Pagy for pagination
- Thanks to all contributors

---

**Note**: This is a development project. For production use, ensure proper security measures, database migration, and environment configuration.
