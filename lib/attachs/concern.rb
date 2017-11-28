module Attachs
  module Concern
    extend ActiveSupport::Concern

    included do
      has_many(
        :attachments,
        class_name: 'Attachs::Attachment',
        dependent: :nullify,
        as: :attachable
      )
    end

    private

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

      def has_attachment?(name)
        attachments.has_key? name.to_sym
      end

    end
  end
end
