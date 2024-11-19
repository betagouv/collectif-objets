# This logger is having the interface is same to `ActiveSupport::TaggedLogging`.
# @see https://github.com/rails/rails/blob/master/activesupport/lib/active_support/tagged_logging.rb
class JsonLogger < ActiveSupport::Logger
    class Formatter < ActiveSupport::Logger::SimpleFormatter
      def call severity, timestamp, progname, message
        JSON.generate({
                        type: severity,
                        time: timestamp.iso8601,
                        progname: progname,
                        message: message,
                        tags: current_tags
                      }) + "\n"
      end
  
      def tagged *tags
        new_tags = push_tags(*tags)
        yield self
      ensure
        pop_tags(new_tags.size)
      end
  
      def push_tags *tags
        tags.flatten.reject(&:blank?).tap do |new_tags|
          current_tags.concat new_tags
        end
      end
  
      def pop_tags size = 1
        current_tags.pop size
      end
  
      def clear_tags!
        current_tags.clear
      end
  
      def current_tags
        # We use our object ID here to avoid conflicting with other instances
        thread_key = @thread_key ||= "activesupport_tagged_logging_tags:#{object_id}"
        Thread.current[thread_key] ||= []
      end
    end
  
    delegate :push_tags, :pop_tags, :clear_tags!, to: :formatter
  
    def initialize *_args
      super
      self.formatter = Formatter.new
    end
  
    def tagged *tags
      formatter.tagged(*tags) { yield self }
    end
  
    def flush
      clear_tags!
      super if defined?(super)
    end
  end
  