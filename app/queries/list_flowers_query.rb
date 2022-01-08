class ListFlowersQuery
  class << self

    def call(options = {})
      paginated_flowers = Flower.includes(:sightings).with_attached_image.paginate(page: options[:page] || 1)
      paginated_flowers.order(created_at: :desc)
    end

  end
end
