require 'test_helper'

class IntegrationTest < ActionDispatch::IntegrationTest

  test 'api' do
    post '/attachments', params: { attachment: { record_type: 'Product', record_attribute: 'brief' } }
    assert_equal attachment.slice(:id).merge(policy: policy, signature: signature), json

    storage.upload pdf_path, attachment.id.to_s, 'application/pdf'

    Attachs::ProcessJob.expects(:perform_later).with attachment
    get "/attachments/#{attachment.id}/queue"
    assert_equal attachment.slice(:id, :urls).merge(state: 'processing'), json

    assert_raises ActiveRecord::RecordNotFound do
      get "/attachments/#{attachment.id}/queue"
    end

    attachment.process

    get "/attachments/#{attachment.id}"
    assert_equal attachment.slice(:id, :urls).merge(state: 'processed'), json
  end

  private

  def json
    case response.parsed_body
    when Hash
      response.parsed_body
    when String
      JSON.parse response.parsed_body
    end
  end

  def attachment
    Attachs::Attachment.last
  end

  def signed_policy
    @signed_policy ||= storage.generate_signed_policy(attachment.requested_at, attachment.id)
  end

  def policy
    signed_policy.first
  end

  def signature
    signed_policy.second
  end

end
