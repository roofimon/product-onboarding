# USER Registration Tutorial

## Overview

This guide walks through implementing a Coinbase-inspired user registration and authentication flow in a fresh Rails 8.1 application. The final result supports:

- User signup with name, surname, email, password, password confirmation
- Automatic login after registration
- Registration success screen
- Login / logout with bcrypt-backed secure passwords
- Reusable authentication helpers (`current_user`, `logged_in?`, `admin?`, `require_login`, `require_admin`)
- Coinbase-style styling for auth pages

All file paths are relative to the Rails app root (`/home/dude/Workspace/Rails/product-onboarding`).

---

## 1. Add bcrypt

Enable password hashing.

```ruby
# Gemfile
gem "bcrypt", "~> 3.1.7"
```

Install the gem:

```sh
bundle install
```

---

## 2. Generate the User model

```sh
rails generate model User name:string surname:string email:string:uniq password_digest:string admin:boolean
```

Update the migration (`db/migrate/*_create_users.rb`):

```ruby
create_table :users do |t|
  t.string :name, null: false
  t.string :surname, null: false
  t.string :email, null: false
  t.string :password_digest, null: false
  t.boolean :admin, default: false, null: false

  t.timestamps
end

add_index :users, :email, unique: true
```

Run the migration:

```sh
rails db:migrate
```

### User model (`app/models/user.rb`)

```ruby
class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :surname, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
end
```

`has_secure_password` relies on bcrypt and adds `password` / `password_confirmation` attributes plus password validation helpers.

---

## 3. Authentication helpers

Modify `app/controllers/application_controller.rb`:

```ruby
class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :current_user, :logged_in?, :admin?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in to access this page"
      redirect_to login_path
    end
  end

  def admin?
    current_user&.admin?
  end

  def require_admin
    unless admin?
      flash[:alert] = "You must be an admin to access this page"
      redirect_to root_path
    end
  end
end
```

These helpers power both registration and login flows.

---

## 4. Registration controller & views

### Controller (`app/controllers/registrations_controller.rb`)

```ruby
class RegistrationsController < ApplicationController
  def new
    if current_user
      redirect_to registration_completed_path
      return
    end
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to registration_completed_path, notice: "Account created successfully! Welcome, #{@user.name}!"
    else
      flash.now[:alert] = "Please fix the errors below"
      render :new, status: :unprocessable_entity
    end
  end

  def completed
    redirect_to root_path unless logged_in?
    @user = current_user
  end

  private

  def user_params
    params.require(:user).permit(:name, :surname, :email, :password, :password_confirmation)
  end
end
```

### Views

#### Signup form (`app/views/registrations/new.html.erb`)

```erb
<div class="auth-container">
  <div class="auth-card">
    <h1 class="auth-title">Create Account</h1>
    
    <% if flash[:alert] %>
      <div class="alert alert-error">
        <%= flash[:alert] %>
      </div>
    <% end %>
    
    <% if @user.errors.any? %>
      <div class="alert alert-error">
        <h4><%= pluralize(@user.errors.count, "error") %> prohibited this account from being created:</h4>
        <ul style="margin-top: var(--spacing-sm); padding-left: var(--spacing-lg);">
          <% @user.errors.full_messages.each do |message| %>
            <li><%= message %></li>
          <% end %>
        </ul>
      </div>
    <% end %>

    <%= form_with model: @user, url: signup_path, method: :post, local: true, class: "auth-form" do |f| %>
      <div class="form-group">
        <%= f.label :name, "First Name", class: "form-label" %>
        <%= f.text_field :name, class: "form-input", placeholder: "Enter your first name", required: true, autofocus: true %>
      </div>
      <div class="form-group">
        <%= f.label :surname, "Last Name", class: "form-label" %>
        <%= f.text_field :surname, class: "form-input", placeholder: "Enter your last name", required: true %>
      </div>
      <div class="form-group">
        <%= f.label :email, "Email", class: "form-label" %>
        <%= f.email_field :email, class: "form-input", placeholder: "Enter your email", required: true %>
      </div>
      <div class="form-group">
        <%= f.label :password, "Password", class: "form-label" %>
        <%= f.password_field :password, class: "form-input", placeholder: "Enter your password (min. 6 characters)", required: true %>
      </div>
      <div class="form-group">
        <%= f.label :password_confirmation, "Confirm Password", class: "form-label" %>
        <%= f.password_field :password_confirmation, class: "form-input", placeholder: "Confirm your password", required: true %>
      </div>
      <div class="form-actions">
        <%= f.submit "Create Account", class: "btn btn-primary btn-block" %>
      </div>
    <% end %>

    <div class="auth-links">
      Already have an account? <%= link_to "Sign in", login_path %>
    </div>
  </div>
</div>
```

#### Completion screen (`app/views/registrations/completed.html.erb`)

```erb
<div class="auth-container">
  <div class="auth-card" style="text-align: center; max-width: 500px;">
    <div style="margin-bottom: var(--spacing-xl);">
      <div style="width: 80px; height: 80px; margin: 0 auto var(--spacing-lg); background-color: var(--color-success); border-radius: 50%; display: flex; align-items: center; justify-content: center;">
        <svg width="40" height="40" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M20 6L9 17L4 12" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
        </svg>
      </div>
      <h1 class="auth-title" style="color: var(--color-success);">Registration Successful!</h1>
    </div>

    <% if flash[:notice] %>
      <div class="alert alert-notice" style="margin-bottom: var(--spacing-lg);">
        <%= flash[:notice] %>
      </div>
    <% end %>

    <div style="margin-bottom: var(--spacing-xl);">
      <p style="font-size: 1.125rem; color: var(--color-text); margin-bottom: var(--spacing-md);">
        Welcome, <strong><%= @user.name %> <%= @user.surname %></strong>!
      </p>
      <p style="color: var(--color-text-secondary); line-height: 1.8;">
        Your account has been successfully created. You're now logged in and ready to get started.
      </p>
    </div>

    <div style="display: flex; flex-direction: column; gap: var(--spacing-md);">
      <%= link_to "Get Started", root_path, class: "btn btn-primary btn-block", style: "font-size: 1rem; padding: var(--spacing-md) var(--spacing-lg);" %>
      <%= link_to "Go to Dashboard", root_path, class: "btn btn-secondary btn-block" %>
    </div>

    <div class="auth-links" style="margin-top: var(--spacing-xl);">
      Need help? <a href="#" style="color: var(--color-primary);">Contact Support</a>
    </div>
  </div>
</div>
```

---

## 5. Sessions (login / logout)

### Controller (`app/controllers/sessions_controller.rb`)

```ruby
class SessionsController < ApplicationController
  def new
    redirect_to root_path if current_user
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)
    
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "Successfully logged in! Welcome back, #{user.name}!"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Successfully logged out!"
  end
end
```

### Login view (`app/views/sessions/new.html.erb`)

```erb
<div class="auth-container">
  <div class="auth-card">
    <h1 class="auth-title">Sign In</h1>
    
    <% if flash[:alert] %>
      <div class="alert alert-error">
        <%= flash[:alert] %>
      </div>
    <% end %>

    <%= form_with url: login_path, method: :post, local: true, class: "auth-form" do |f| %>
      <div class="form-group">
        <%= f.label :email, "Email", class: "form-label" %>
        <%= f.email_field :email, class: "form-input", placeholder: "Enter your email", required: true, autofocus: true %>
      </div>
      <div class="form-group">
        <%= f.label :password, "Password", class: "form-label" %>
        <%= f.password_field :password, class: "form-input", placeholder: "Enter your password", required: true %>
      </div>
      <div class="form-actions">
        <%= f.submit "Sign In", class: "btn btn-primary btn-block" %>
      </div>
    <% end %>

    <div class="auth-links">
      Don't have an account? <%= link_to "Sign up", signup_path %>
    </div>
  </div>
</div>
```

---

## 6. Routes (`config/routes.rb`)

```ruby
Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "signup", to: "registrations#new", as: :signup
  post "signup", to: "registrations#create"
  get "registration/completed", to: "registrations#completed", as: :registration_completed

  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  root "registrations#new"
end
```

- Root path shows the signup form. Adjust as needed for your dashboard.
- Registration completion page is only accessible to logged in users.

---

## 7. Coinbase-style design system

`app/assets/stylesheets/application.css` contains a lightweight CSS design system:

- CSS variables for color palette, spacing, typography
- Buttons, cards, alerts, form styles
- Auth page layout classes (`auth-container`, `auth-card`, etc.)
- Responsive tweaks for smaller screens

Customize tokens and utility classes to extend the design.

---

## 8. Manual flow verification

1. Visit `http://localhost:3000/signup`
2. Fill in name, surname, email, password, confirmation
3. Submit the form ➜ user is created and auto-logged-in
4. Redirected to `/registration/completed` success screen
5. Navigate to `/login` to test sign-in
6. Submit with the same credentials
7. Log out via a link hitting `DELETE /logout`

Check the SQLite database to confirm records:

```sh
sqlite3 storage/development.sqlite3 "SELECT name, surname, email, admin FROM users;"
```

---

## 9. Next steps

- Add navigation and dashboards referencing `current_user`
- Implement password reset flow (`has_secure_token`, Action Mailer)
- Add admin-only sections guarded by `require_admin`
- Integrate with your future product onboarding and auction modules

With this foundation, the app supports secure, user-friendly onboarding that matches the Coinbase aesthetic.
