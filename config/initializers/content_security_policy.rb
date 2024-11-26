# frozen_string_literal: true

Rails.application.configure do
  config.content_security_policy do |policy|

    if Rails.configuration.x.environment_specific_name == "production"
      s3_uris = [
        "https://collectif-objets-production.s3.fr-par.scw.cloud/",
        "https://s3.fr-par.scw.cloud/collectif-objets-production/",
        "https://collectif-objets-public.s3.fr-par.scw.cloud/",
        "https://s3.fr-par.scw.cloud/collectif-objets-public/"
      ]

      policy.report_uri "https://sentry.incubateur.net/api/40/security/?sentry_key=5f6f9cf638ac413b82d1d9c8a9ba2025"

    elsif Rails.configuration.x.environment_specific_name == "staging"
      s3_uris = [
        "https://collectif-objets-staging2.s3.fr-par.scw.cloud/",
        "https://s3.fr-par.scw.cloud/collectif-objets-staging2/",
        "https://collectif-objets-public.s3.fr-par.scw.cloud/",
        "https://s3.fr-par.scw.cloud/collectif-objets-public/"
      ]

    elsif Rails.configuration.x.environment_specific_name == "mc_stg"
      s3_uris = [
        "https://collectif-objets-staging2.s3.gra.io.cloud.ovh.net/",
        "https://s3.gra.io.cloud.ovh.net/collectif-objets-staging2/",
        "https://collectif-objets-public.s3.gra.io.cloud.ovh.net/",
        "https://s3.gra.io.cloud.ovh.net/collectif-objets-public/"
      ]

    else # Env development
      s3_uris = [
        "https://collectif-objets-development2.s3.fr-par.scw.cloud/",
        "https://s3.fr-par.scw.cloud/collectif-objets-development2/",
        "https://collectif-objets-public.s3.fr-par.scw.cloud/",
        "https://s3.fr-par.scw.cloud/collectif-objets-public/"
      ]

    end

    policy.default_src :self, :https
    policy.script_src  :self, :https
    policy.img_src \
      :self,
      :data,
      :blob, # cf https://maplibre.org/maplibre-gl-js-docs/api/#csp-directives
      "https://s3.eu-west-3.amazonaws.com/pop-phototeque/",
      "https://pop-perf-assets.s3.gra.io.cloud.ovh.net/",
      "https://collectif-objets.beta.gouv.fr/", # for mail previews
      "https://stats.beta.gouv.fr",
      *s3_uris

    policy.connect_src \
      :self,
      "https://stats.beta.gouv.fr",
      "https://openmaptiles.geo.data.gouv.fr",
      *(Rails.env.development? ? ["ws://#{ ViteRuby.config.host_with_port }"] : []),
      *s3_uris

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
