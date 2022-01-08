class LikeSerializer < ActiveModel::Serializer

  attributes :id, :user, :sighting_id, :created_at

  def user
    {
      id: object.user.id,
      username: object.user.username
    }
  end

end
