class CollectionsController < ApplicationController
  before_action :set_collection, only: [:show, :edit, :update, :destroy]

  def index
    @collections = Collection.all.order(created_at: :desc)
    @products = Product.includes(:product_variants, :collection).paginate(page: params[:page], per_page: 3)
    
    # Apply filters
    @products = filter_by_search(@products)
    @products = filter_by_collection(@products)
    @products = filter_by_category(@products)
    @products = filter_by_discount(@products)
    @products = filter_by_rating(@products)
    @products = filter_by_price(@products)
    
    # Get filter options
    @categories = Product.distinct.pluck(:category).compact.sort
    @collections_list = Collection.all
    
    # Handle AJAX requests
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @products = @collection.products.includes(:product_variants)
    
    # Apply filters
     @products = filter_by_search(@products)
    @products = filter_by_category(@products)
    @products = filter_by_discount(@products)
    @products = filter_by_rating(@products)
    @products = filter_by_price(@products)
    
    # Get filter options
    @categories = @collection.products.distinct.pluck(:category).compact.sort
    @collections_list = Collection.all
  end

  def new
    @collection = Collection.new
  end

  def create
    @collection = Collection.new(collection_params)
    
    if @collection.save
      redirect_to collections_path, notice: 'Collection was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @collection.update(collection_params)
      redirect_to collections_path, notice: 'Collection was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @collection.destroy
    redirect_to collections_path, notice: 'Collection was successfully deleted.'
  end

  private
  
  def set_collection
    @collection = Collection.find(params[:id])
  end
  
  def collection_params
    params.require(:collection).permit(:name, :description)
  end
  
  def filter_by_collection(products)
    if params[:collection_id].present?
      products.where(collection_id: params[:collection_id])
    elsif params[:collection].present?
      # Find collection by name (case-insensitive) and filter products
      collection = Collection.where('LOWER(name) = LOWER(?)', params[:collection]).first
      if collection
        products.where(collection_id: collection.id)
      else
        products
      end
    else
      products
    end
  end
  
  def filter_by_category(products)
    if params[:category].present?
      products.where(category: params[:category])
    else
      products
    end
  end
  
  def filter_by_discount(products)
    if params[:min_discount].present?
      products.where('discount_percentage >= ?', params[:min_discount])
    else
      products
    end
  end
  
  def filter_by_rating(products)
    if params[:min_rating].present?
      products.where('rating >= ?', params[:min_rating])
    else
      products
    end
  end
  
  def filter_by_price(products)
    if params[:min_price].present? || params[:max_price].present?
      products = products.joins(:product_variants)
      
      if params[:min_price].present?
        products = products.where('product_variants.price >= ?', params[:min_price])
      end
      
      if params[:max_price].present?
        products = products.where('product_variants.price <= ?', params[:max_price])
      end
      
      products.distinct
    else
      products
    end
  end
  def filter_by_search(products)
  if params[:search].present?
    products.where(
      "LOWER(products.name) LIKE LOWER(?)",
      "%#{params[:search]}%"
    )
  else
    products
  end
end

end
