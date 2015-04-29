# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = (ENV["ASSETS_VERSION"] || "1.0")

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
teaspoon = %w( teaspoon.css jasmine/1.3.1.js teaspoon-teaspoon.js teaspoon-jasmine.js )
bookmarklet = %w( api/bookmarklets/view.js sections/bookmarklet.css )
mailer = %w( mailer.css )

Rails.application.config.assets.precompile += [teaspoon, bookmarklet, mailer].flatten