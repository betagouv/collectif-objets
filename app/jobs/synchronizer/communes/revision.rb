# frozen_string_literal: true

module Synchronizer
  module Communes
    class Revision
      include LogConcern

      def initialize(commune_and_user_attributes, logger: nil, persisted_commune: nil)
        @commune_and_user_attributes = commune_and_user_attributes
        @persisted_commune = persisted_commune
        @logger = logger
        @persisted_user = persisted_commune&.users&.first
        verify_eager_loaded_commune_code_insee!
      end

      def synchronize
        return false unless check_valid

        log_changes
        commune.save!
      end

      def destroy_user? = users_attributes&.first&.key?(:_destroy)

      delegate :to_s, to: :all_attributes

      def action_commune
        @action_commune ||=
          if commune.new_record?
            :create
          elsif commune.changed?
            :update
          end
      end

      def action_user
        @action_user ||=
          if commune.persisted? && destroy_user?
            :destroy
          elsif commune.persisted? && persisted_user
            :update
          else
            :create
          end
      end

      private

      attr_reader :commune_and_user_attributes, :persisted_commune, :persisted_user

      # def log(*, **) = puts(*, **) # for debug

      def verify_eager_loaded_commune_code_insee!
        return if persisted_commune.nil? || persisted_commune.code_insee == commune_attributes[:code_insee]

        raise "eager loaded commune #{persisted_commune.code_insee} instead of #{commune_attributes[:code_insee]}"
      end

      def commune
        @commune ||= (persisted_commune || Commune.new).tap { _1.assign_attributes(all_attributes) }
      end

      def commune_attributes = commune_and_user_attributes[:commune]
      def user_attributes = commune_and_user_attributes[:user]

      def all_attributes
        commune_attributes.merge({ users_attributes: }.compact)
      end

      def users_attributes
        @users_attributes ||=
          if persisted_user && user_attributes[:email].present?
            [{ id: persisted_user.id, email: user_attributes[:email] }]
          elsif persisted_user
            [{ id: persisted_user.id, _destroy: true }]
          elsif user_attributes[:email].present?
            [{ email: user_attributes[:email], magic_token: SecureRandom.hex(10) }]
          end
      end

      def check_valid
        return true if commune.valid?

        log "commune synchro rejected : #{commune_attributes[:code_insee]} #{commune_attributes[:nom]} : " \
            "#{commune.errors.full_messages.to_sentence} - #{all_attributes}",
            counter: :error
        false
      end

      def log_changes
        if action_commune == :create
          log "creating commune #{commune_attributes[:code_insee]} with #{all_attributes}", counter: :create_commune
        elsif action_commune == :update
          log "saving changes to commune #{commune_attributes[:code_insee]} #{commune.changes}",
              counter: :update_commune
        end

        if action_user == :update
          log "saving email change #{persisted_user.email} -> #{user_attributes[:email]}",
              counter: :user_update_email
        elsif action_user == :destroy
          log "destroying user #{persisted_user.email} for commune #{commune_attributes[:code_insee]}",
              counter: :user_destroyed
        end
      end
    end
  end
end
