Makers.define do
  maker :business do
    name 'Test'
  end

  maker :product do
  end

  maker :attachment, class_name: 'Attachs::Attachment' do
    trait :processing do
      state 'processing'
    end

    trait :processed do
      state 'processed'
      processed_at { Time.zone.now + 1.hour }
    end

    maker :image do
      record_type 'Business'
      record_attribute 'logo'
      content_type 'image/jpeg'
      extension 'jpg'
      size 2.megabytes

      trait :attached do
        association :record, maker: :business
      end
    end

    maker :pdf do
      record_type 'Product'
      record_attribute 'brief'
      content_type 'application/pdf'
      extension 'pdf'
      size 120.kilobytes

      trait :attached do
        association :record, maker: :product
      end
    end
  end
end
