module ImageLoaders

  class FsImageLoader < ImageLoader
    def load_flowers_images
      Dir.glob("storage/flowers/*").to_a
    end

  end
end
