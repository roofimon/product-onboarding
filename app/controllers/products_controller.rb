class ProductsController < ApplicationController
  before_action :require_login, except: [ :index ]
  before_action :set_product, only: [ :show ]

  def index
    @products = Product.all.order(created_at: :desc)
  end

  def new
    @product = Product.new
  end

  def create
    @product = current_user.products.build(product_params)

    if @product.save
      redirect_to @product, notice: "Product was successfully created!"
    else
      flash.now[:alert] = "Please fix the errors below"
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  private

  def product_params
    params.require(:product).permit(:name, :description, :open_price, :price_per_bid)
  end

  def set_product
    @product = Product.find(params[:id])
  end
end
