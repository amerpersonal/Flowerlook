class ListSightingsQuery

  class << self
    def call(flower, options = {})
      sightings = Sighting.where(flower_id: flower.id).joins(:user).joins(:flower).includes(:likes, :user, :flower).with_attached_image
      paginated_results = sightings.paginate(page: options[:page] || 1)
      paginated_results.order(created_at: :desc)
    end
  end
end
