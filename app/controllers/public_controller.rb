class PublicController < ApplicationController
  before_action :set_product, only: [:show]

  def index
    @products = Product.all
    
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @products = @products.where(
        "name LIKE ? OR description LIKE ?", 
        search_term, 
        search_term
      )
    end
    
    # Apply sorting
    case params[:sort]
    when 'price_low_high'
      @products = @products.order(open_price: :asc)
    when 'price_high_low'
      @products = @products.order(open_price: :desc)
    else
      @products = @products.order(created_at: :desc)
    end
  end

  def show
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end
end

