# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = (ENV["ASSETS_VERSION"] || "1.0")

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += [ 
  'api/bookmarklets/view.js', 
  'sections/bookmarklet.css',   
  'icons.eot',
  'icons.svg',
  'icons.ttf',
  'icons.woff', 
  'teaspoon.css',
  'jasmine/1.3.1.js',
  'teaspoon-teaspoon.js',
  'teaspoon-jasmine.js'
]

Rails.application.config.assets.paths += [
  Rails.root.join('vendor', 'assets', 'fonts'),
]