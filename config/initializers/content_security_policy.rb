# frozen_string_literal: true

Rails.application.configure do
  # We will only report breaches for a while, then actually enforce these CSP rules by removing this line
  config.content_security_policy_report_only = true

  s3_buckets = %w[development2 staging2 production public photos-overrides].map { "collectif-objets-#{_1}" }

  config.content_security_policy do |policy|
    # Specify URI for violation reports
    policy.report_uri "https://sentry.incubateur.net/api/40/security/?sentry_key=5f6f9cf638ac413b82d1d9c8a9ba2025"

    policy.default_src :self, :https
    policy.script_src  :self, :https
    policy.img_src :self, :data,
                   "https://s3.eu-west-3.amazonaws.com/pop-phototeque/",
                   *s3_buckets.map { "https://s3.fr-par.scw.cloud/#{_1}/" },
                   "https://collectif-objets.beta.gouv.fr/" # for mail previews
    policy.connect_src :self,
                       "https://sentry.incubateur.net",
                       "https://stats.data.gouv.fr",
                       *s3_buckets.map { "https://#{_1}.s3.fr-par.scw.cloud/" }
    policy.object_src  :none
    policy.style_src   :self, :https,
                       "'sha256-47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU='", # for frappe-charts cf https://github.com/frappe/charts/issues/378
                       "'sha256-CssDN67+wdcVeOo1+UBDlTtUvWjUmBJyiyqqRJHhrTQ='"  # same
    policy.font_src    :self, :https, :data

    if Rails.env.development?
      # tweaks for vite-dev HMR
      # policy.script_src *policy.script_src, :unsafe_eval, "http://#{ ViteRuby.config.host_with_port }"
      # policy.style_src *policy.style_src, :unsafe_inline, "ws://#{ ViteRuby.config.host_with_port }"
      policy.connect_src *policy.connect_src, "ws://#{ ViteRuby.config.host_with_port }", "http://#{ ViteRuby.config.host_with_port }"
      # policy.script_src *policy.script_src, :unsafe_eval,
      # policy.style_src *policy.style_src, :unsafe_inline
    elsif Rails.env.test?
      policy.script_src *policy.script_src, :blob
    end
  end

  # Generate session nonces for permitted importmap and inline scripts
  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w(script-src style-src)
end
