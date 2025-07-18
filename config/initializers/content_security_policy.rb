# frozen_string_literal: true

Rails.application.configure do
  # Domaines autorisés (upload, images, et stats)
  domains = [
    # OVH
    "https://*.s3.gra.io.cloud.ovh.net",
    # SCALEWAY
    "https://*.s3.fr-par.scw.cloud",
    "https://s3.fr-par.scw.cloud",
    # Culture
    "https://*.culture.gouv.fr",
    "https://*.cloud.culture.fr",
    # stats
    "https://stats.beta.gouv.fr",
  ]

  config.content_security_policy do |policy|
    if Rails.configuration.x.environment_specific_name == "production"
      policy.report_uri "https://sentry.incubateur.net/api/40/security/?sentry_key=5f6f9cf638ac413b82d1d9c8a9ba2025"
    end

    policy.default_src :self, :https
    policy.script_src  :self, :https
    policy.img_src \
      :self,
      :data,
      :blob, # cf https://maplibre.org/maplibre-gl-js-docs/api/#csp-directives
      *domains,
      "https://s3.eu-west-3.amazonaws.com/pop-phototeque/",
      "https://pop-perf-assets.s3.gra.io.cloud.ovh.net/",
      "https://collectif-objets.beta.gouv.fr/" # for mail previews

    policy.connect_src \
      :self,
      "https://openmaptiles.geo.data.gouv.fr",
      "https://openmaptiles.data.gouv.fr",
      *domains,
      *(Rails.env.development? ? ["ws://#{ViteRuby.config.host_with_port}", "ws://127.0.0.1:#{ViteRuby.config.port}"] : [])

    policy.object_src :self # for the PDFs served by the rails server
    policy.font_src :self, :https, :data
    policy.child_src :blob # cf https://maplibre.org/maplibre-gl-js-docs/api/#csp-directives
    policy.worker_src :blob # cf https://maplibre.org/maplibre-gl-js-docs/api/#csp-directives

    policy.style_src :self, :https

    policy.frame_src :self, # for the PDFs served by the rails server through <embed> cf https://stackoverflow.com/a/69147536
      "https://collectif-objets-metabase.osc-secnum-fr1.scalingo.io/",
      "https://tube.numerique.gouv.fr/"
  end

  # Generate session nonces for permitted importmap and inline scripts
  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }

  nonce_directives = %w(script-src)
  config.content_security_policy_nonce_directives = nonce_directives
end
