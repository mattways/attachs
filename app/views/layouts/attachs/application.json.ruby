if @attachment.errors.any?
  { errors: @attachment.errors.full_messages }
else
  yield
end
