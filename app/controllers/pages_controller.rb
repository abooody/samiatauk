class PagesController < ApplicationController

  after_filter(:except => :contato) {|c| c.cache_page}

  def index
    @page = Page.find_by_permalink("home")
    @posts = Post.all(:limit => 3)
    @photo_gallery = PhotoGallery.first
    @images = Image.all(:limit => 4, :conditions => ["photo_gallery_id = ?", @photo_gallery.id]) rescue ""
    @metatag_object = @page
  end

  def contato
    @page = Page.find_by_permalink('contato')
    if request.post?
      Mailer.deliver_contact(params[:contact])
      flash[:notice] = "Sua mensagem foi enviada."
    end
    @metatag_object = @page
  end

  def method_missing(method, *args)
    @page = Page.find_by_permalink(method) || @page = Page.page_not_found
    @pages = @page.pages || []
    @metatag_object = @page
    send(method.underscore) if respond_to?(method.underscore)

    render method.underscore
    rescue ActionView::MissingTemplate
      render 'show'
  end
  
  def sitemap
    @pages = Page.all
    @posts = Post.all
    @downloads = Download.all
    @photo_galleries = PhotoGallery.with_images
    
    respond_to do |format|
      format.html
      format.xml
    end
  end

end

