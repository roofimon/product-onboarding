class PublicController < ApplicationController
  before_action :set_product, only: [:show]

  def index
    @products = Product.all.order(created_at: :desc)
    
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @products = @products.where(
        "name LIKE ? OR description LIKE ?", 
        search_term, 
        search_term
      )
    end
  end

  def show
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end
end

