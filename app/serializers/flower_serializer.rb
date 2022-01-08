class FlowerSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :name, :image, :updated_at

  # we want to show resized image inside list, for better show in grid or list view
  def image
    url_for(object.image.variant(resize: "100x100"))
  end
end
