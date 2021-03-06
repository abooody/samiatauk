class Admin::PhotoGalleriesController < Admin::AdminController
  
  cache_sweeper :photo_gallery_sweeper
  create.wants.html {redirect_to(collection_url)}
  update.wants.html {redirect_to(collection_url)}
  
  include Order
end
