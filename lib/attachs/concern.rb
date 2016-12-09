module Attachs
  module Concern
    extend ActiveSupport::Concern

    included do
      before_save :persist_attachments
      after_commit :save_attachments, on: %i(create update)
      after_commit :destroy_attachments, on: :destroy
      after_rollback :unpersist_attachments
    end

    def reload(options=nil)
      clear_attachments
      super
    end

    private

    def initialize_dup(other)
      clear_attachments
      super
    end

    def clear_attachments
      self.class.attachments.keys.each do |attribute|
        instance_variable_set "@#{attribute}", nil
      end
    end

    %i(save destroy persist unpersist).each do |method|
      define_method "#{method}_attachments" do
        self.class.attachments.keys.each do |attribute|
          send(attribute).send method
        end
      end
    end

    module ClassMethods

      def inherited(subclass)
        subclass.instance_variable_set :@attachments, @attachments
        super
      end

      def attachments
        @attachments ||= {}
      end

      def attachable?
        attachments.any?
      end

    end
  end
end
