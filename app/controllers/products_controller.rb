class ProductsController < ApplicationController
  before_action :set_product, only: [:show]

  def index
    @products = Product.includes(:product_variants).all
  end

  def show
    @variants = @product.product_variants.in_stock
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name,
      :description,
      :rating,
      :featured,
      :image,
      :collection_id,
      :category,
      :discount_percentage,
      product_variants_attributes: [
        :id,
        :variant_type,
        :value,
        :price,
        :inventory_quantity,
        :_destroy
      ]
    )
  end
end
