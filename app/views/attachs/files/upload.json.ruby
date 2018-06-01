@attachment.slice(:id).tap do |hash|
  if @attachment.processed?
    hash[:urls] = @attachment.urls
  else
    hash[:chunk] = params[:chunk].to_i
  end
end
