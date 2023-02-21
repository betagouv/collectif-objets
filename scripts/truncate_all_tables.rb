# frozen_string_literal: true

raise if Rails.configuration.x.environment_specific_name == "production"

ActiveRecord::Base.connection.truncate_tables(*ActiveRecord::Base.connection.tables)
