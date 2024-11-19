class SimpleJSONLogFormatter < ActiveSupport::Logger::SimpleFormatter
    def call(severity, timestamp, _progname, message)
      { 
        type: severity,
        time: timestamp,
        message: message
      }.to_json
    end
end
  