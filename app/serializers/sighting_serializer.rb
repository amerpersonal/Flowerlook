class SightingSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :longitude, :latitude, :user, :flower, :image, :likes_count, :question

  def user
    {
      id: object.user.id,
      username: object.user.username
    }
  end

  def flower
    {
      id: object.flower.id,
      name: object.flower.name
    }
  end

  # we want to show resized image inside list, for better show in grid or list view
  def image
    url_for(object.image.variant(resize: "100x100"))
  end

  def likes_count
    object.likes.size
  end
end
