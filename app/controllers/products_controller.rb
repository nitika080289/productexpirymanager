class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])
    render json: @product
  end

  def index
    @product = Product.all
    render json: @product
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
    @product = Product.new(params[:product])
    if @product.save
      render json: @product
    else
      render error: { error: 'Unable to save product.' }, status: 400
    end
  end
end
