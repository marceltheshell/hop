#
# Customize premailer settings
#
Premailer::Rails.config.merge!(
  adapter: :nokogiri,
  preserve_styles: false, 
  remove_ids: true
)
