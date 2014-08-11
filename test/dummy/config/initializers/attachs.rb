Attachs.configure do |config|

  config.global_styles = [:small, :medium, :big]
  config.global_convert_options = '-quality 75'
  config.styles = {
    small: '120x120!',
    medium: '300x250#',
    big: '1024x768',
    big_contain: '160x130',
    small_contain: '140x110',
    big_cover: '160x130#',
    small_cover: '140x110#',
    big_force: '160x130!',
    small_force: '140x110!'
  }
  config.convert_options = {
    big_contain: '-trim',
    big_cover: '-trim',
    big_force: '-trim'
  }
  config.interpolations = {
    month: lambda { |attachment| attachment.updated_at.month }
  }

end
