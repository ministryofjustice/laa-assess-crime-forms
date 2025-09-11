module Steps
  class BaseStepController < ::ApplicationController
    helper StepsHelper
    helper FormBuilderHelper

    # :nocov:
    def show
      raise 'implement this action, if needed, in subclasses'
    end

    def edit
      raise 'implement this action, if needed, in subclasses'
    end

    def update
      raise 'implement this action, if needed, in subclasses'
    end
    # :nocov:

    def reload
      @form_object.valid?
      render :edit
    end

    private

    def current_application
      raise 'implement this action, in subclasses'
    end

    # :nocov:
    def decision_tree_class
      raise 'implement this action, in subclasses'
    end
    # :nocov:

    def update_and_advance(form_class, opts = {})
      # replace current_application with session_form
      hash = permitted_params(form_class).to_h
      @form_object = form_class.build(hash, multi_step_form_session:)

      process_form(@form_object, opts)
    end

    def process_form(form_object, opts)
      if form_object.save
        redirect_to decision_tree_class.new(form_object, as: opts.fetch(:as)).destination, flash: opts[:flash]
      else
        render opts.fetch(:render, :edit)
      end
    end

    def permitted_params(form_class)
      params
        .fetch(form_class.model_name.singular, {})
        .permit(form_class.attribute_names)
    end

    # :nocov:
    def subsequent_steps
      []
    end
    # :nocov:

    def render_form_if_invalid(form_object, opts)
      if form_object.validate
        redirect_to_current_object
      else
        render opts.fetch(:render, :edit)
      end
    end
  end
end
