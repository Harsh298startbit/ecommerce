class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: [:edit, :update, :destroy]
  
  def index
    @products = Product.includes(:collection).order(created_at: :desc).page(params[:page]).per_page(20)
  end
  
  def new
    @product = Product.new
    @product.product_variants.build  # Initialize with one variant field
    @collections = Collection.all
  end
  
  def create
    @product = Product.new(product_params)
    
    if @product.save
      redirect_to admin_products_path, notice: "Product created successfully."
    else
      @collections = Collection.all
      render :new
    end
  end
  
  def edit
    @collections = Collection.all
  end
  
  def update
    if @product.update(product_params)
      redirect_to admin_products_path, notice: "Product updated successfully."
    else
      @collections = Collection.all
      render :edit
    end
  end
  
  def destroy
    @product.destroy
    redirect_to admin_products_path, notice: "Product deleted successfully."
  end
  
  private
  
  def set_product
    @product = Product.find(params[:id])
  end
  
  def product_params
    params.require(:product).permit(
      :name, 
      :description, 
      :collection_id, 
      :featured, 
      :category, 
      :image,
      :rating,
      :discount_percentage,
      product_variants_attributes: [:id, :variant_type, :value, :price, :inventory_quantity, :_destroy]
    )
  end
end
