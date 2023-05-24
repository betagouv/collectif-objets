# frozen_string_literal: true

Rails.application.configure do
  # We will only report breaches for a while, then actually enforce these CSP rules by removing this line
  config.content_security_policy_report_only = true

  s3_buckets = %w[development2 staging2 production public photos-overrides].map { "collectif-objets-#{_1}" }

  config.content_security_policy do |policy|
    # Specify URI for violation reports
    if Rails.configuration.x.environment_specific_name == "production"
      policy.report_uri "https://sentry.incubateur.net/api/40/security/?sentry_key=5f6f9cf638ac413b82d1d9c8a9ba2025"
    end

    policy.default_src :self, :https
    policy.script_src  :self, :https
    policy.img_src \
      :self,
      :data,
      :blob, # cf https://maplibre.org/maplibre-gl-js-docs/api/#csp-directives
      "https://s3.eu-west-3.amazonaws.com/pop-phototeque/",
      *s3_buckets.map { "https://s3.fr-par.scw.cloud/#{_1}/" },
      "https://collectif-objets.beta.gouv.fr/" # for mail previews

    policy.connect_src \
      :self,
      "https://sentry.incubateur.net",
      "https://stats.data.gouv.fr",
      "https://openmaptiles.geo.data.gouv.fr",
      *s3_buckets.map { "https://#{_1}.s3.fr-par.scw.cloud/" },
      *(Rails.env.development? ? ["ws://#{ ViteRuby.config.host_with_port }"] : [])

    policy.object_src  :none
    policy.font_src :self, :https, :data
    policy.child_src :blob # cf https://maplibre.org/maplibre-gl-js-docs/api/#csp-directives
    policy.worker_src :blob # cf https://maplibre.org/maplibre-gl-js-docs/api/#csp-directives

    inline_css_hashes = %w(
      'sha256-47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU='
      'sha256-CssDN67+wdcVeOo1+UBDlTtUvWjUmBJyiyqqRJHhrTQ='
    )
    # for frappe-charts cf https://github.com/frappe/charts/issues/378
    # NOTE: single quotes are important
    policy.style_src :self, :https, *(Rails.env.development? ? [:unsafe_inline] : inline_css_hashes)
  end

  # Generate session nonces for permitted importmap and inline scripts
  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }

  nonce_directives = %w(script-src)
  nonce_directives += %w(style-src) unless Rails.env.development?
  config.content_security_policy_nonce_directives = nonce_directives
end
