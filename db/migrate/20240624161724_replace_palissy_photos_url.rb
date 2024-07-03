class ReplacePalissyPhotosUrl < ActiveRecord::Migration[7.1]
  def up
    ReplacePalissyPhotosUrl.replace_palissy_photos_url(MEMOIRE_PHOTOS_AWS_BASE_URL, MEMOIRE_PHOTOS_BASE_URL)
  end

  def down
    ReplacePalissyPhotosUrl.replace_palissy_photos_url(MEMOIRE_PHOTOS_BASE_URL, MEMOIRE_PHOTOS_AWS_BASE_URL)
  end

  private
    def self.replace_palissy_photos_url(from_base_url, to_base_url)
      progress_bar = ProgressBar.create(title: "Avancement de la migration", total: Objet.count, format: "%t: |%W|")
      Objet.find_each do |objet|
        progress_bar.increment
        next if objet.palissy_photos.empty?

        objet.palissy_photos.each do |palissy_photo|
          palissy_photo["url"] = palissy_photo["url"].sub(from_base_url, to_base_url)
        end
        objet.save
      end
    end
end
