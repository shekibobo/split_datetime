module TimeSplitter
  module Accessors
    def split_accessor(*attrs)
      options = { date_format: "%F", time_format: "%R" }.merge!(attrs.extract_options!)

      attrs.each do |attr|
        # Maps the setter for #{attr}_time to accept multipart-parameters for Time
        composed_of "#{attr}_time".to_sym, class_name: 'DateTime' if self.respond_to?(:composed_of)

        # Default instance of the attribute, used if setting an element of the
        # time attribute before the attribute was sent. Allows us to retrieve a
        # default value for +#{attr}+ to modify without explicitely overriding
        # the attr_reader. Defaults to a Time object with all fields set to 0.
        define_method("#{attr}_or_new") do
          self.send(attr) || options.fetch(:default, ->{ Time.new(0, 1, 1, 0, 0, 0, "+00:00") }).call
        end

        # Writers

        define_method("#{attr}_date=") do |date|
          return unless date.present?
          date = Date.parse(date.to_s)
          self.send("#{attr}=", self.send("#{attr}_or_new").change(year: date.year, month: date.month, day: date.day))
        end

        define_method("#{attr}_hour=") do |hour|
          return unless hour.present?
          self.send("#{attr}=", self.send("#{attr}_or_new").change(hour: hour, min: self.send("#{attr}_or_new").min))
        end

        define_method("#{attr}_min=") do |min|
          return unless min.present?
          self.send("#{attr}=", self.send("#{attr}_or_new").change(min: min))
        end

        define_method("#{attr}_time=") do |time|
          return unless time.present?
          time = Time.parse(time) unless time.is_a?(Date) || time.is_a?(Time)
          self.send("#{attr}=", self.send("#{attr}_or_new").change(hour: time.hour, min: time.min))
        end

        # Readers
        define_method("#{attr}_date") do
          self.send(attr).try :strftime, options[:date_format]
        end

        define_method("#{attr}_hour") do
          self.send(attr).try :hour
        end

        define_method("#{attr}_min") do
          self.send(attr).try :min
        end

        define_method("#{attr}_time") do
          self.send(attr).try :strftime, options[:time_format]
        end
      end
    end
  end
end
