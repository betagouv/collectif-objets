# Configure ViteRuby for compatibility with Vite 5
# This initializer implements a workaround for Vite 5 compatibility with vite_ruby gem
# Vite 5 places the manifest in a .vite/ subdirectory, but vite_ruby expects it in the root

Rails.application.config.middleware.use(
  Rack::Static,
  urls: ["/vite-dev", "/vite-test", "/vite"],
  root: "public"
)

# This initializer ensures that Vite 5 manifests are available to the vite_ruby gem
# by copying them from the .vite/ subdirectory to the location expected by vite_ruby
Rails.application.config.after_initialize do
  # Only apply this in environments where we use Vite assets
  if Rails.env.production? || Rails.env.development? || Rails.env.test?
    vite_dir = Rails.root.join("public", "vite-#{Rails.env}")
    
    if File.directory?(vite_dir)
      # Check for Vite 5 manifest in .vite/ subdirectory
      vite5_manifest = File.join(vite_dir, ".vite", "manifest.json")
      expected_manifest = File.join(vite_dir, "manifest.json")
      
      if File.exist?(vite5_manifest) && (!File.exist?(expected_manifest) || File.size(expected_manifest) <= 4)
        begin
          FileUtils.mkdir_p(File.dirname(expected_manifest))
          FileUtils.cp(vite5_manifest, expected_manifest)
          
          # Also copy the assets manifest if it exists
          vite5_assets_manifest = File.join(vite_dir, ".vite", "manifest-assets.json")
          expected_assets_manifest = File.join(vite_dir, "manifest-assets.json")
          
          if File.exist?(vite5_assets_manifest)
            FileUtils.cp(vite5_assets_manifest, expected_assets_manifest)
          end
          
          Rails.logger.info "Copied Vite 5 manifests for compatibility with vite_ruby gem"
        rescue => e
          Rails.logger.error "Error copying Vite 5 manifest: #{e.message}"
        end
      end
    end
  end
end
