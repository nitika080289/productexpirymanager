class ProductsController < ApplicationController
  protect_from_forgery with: :null_session
  def show
    @product = Product.find(params[:id])
    render json: @product
  end

  def index
    @products = Product.where('user_id = ' + current_user.id.to_s)
    render json: @products
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    if @product.destroy
      render json: { message: 'Product deleted successfully' }, status: 200
    else
      render json: { error: 'Unable to delete product' }, status: 400
    end
  end

  def create
    @product = Product.new(product_params)
    @product.created_at = Time.now
    @product.updated_at = Time.now
    @product.user_id = current_user.id
    if @product.save
      render json: @product
    else
      render json: { error: 'Unable to create product' }, status: 400
    end
  end

  def product_params
    params.require(:product).permit(:name, :expiry_date, :quantity)
  end
end
