# frozen_string_literal: true

module Form
  class LabelComponent < ViewComponent::Base
    def initialize(form:, method:)
      @form = form
      @method = method
    end
  end
end
