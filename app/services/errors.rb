class Errors < ApplicationService
  attr_reader :messages

  def initialize
    @messages = nil
  end

  def add(message)
    @messages = message
  end

  def any?
    !@messages.empty?
  end
end
