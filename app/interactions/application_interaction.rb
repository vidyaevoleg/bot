class ApplicationInteraction < ActiveInteraction::Base
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include ActionView::Helpers::TranslationHelper
  extend Memoist

  def initialize(inputs = {})
    inputs = normalize_inputs!(inputs)
    process_inputs(inputs.symbolize_keys)
  end

  def valid?(*)
    if instance_variable_defined?(:@_interaction_valid)
      return @_interaction_valid
    end

    if errors.any?
      return @_interaction_valid = false
    end

    super
  end

  def invalid?
    not valid?
  end

  private

  def compose(other, *args)
    outcome = other.run(*args)
    errors.merge!(outcome.errors) if outcome.invalid?
    outcome
  end
end
