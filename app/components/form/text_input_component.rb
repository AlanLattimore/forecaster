# frozen_string_literal: true

class Form::TextInputComponent < ViewComponent::Base
  def initialize(form:, method:, **input_opts)
    @form = form
    @method = method
    @input_opts = input_opts
  end
end
