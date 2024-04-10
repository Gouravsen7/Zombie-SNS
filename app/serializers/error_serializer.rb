class ErrorSerializer
  def self.serialize(errors)
    return if errors.nil?

    serialized_errors = errors.messages.map do |field, messages|
      messages.map do |message|
        { field: field, message: message }
      end
    end.flatten

    { errors: serialized_errors }
  end
end