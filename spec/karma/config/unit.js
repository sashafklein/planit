// Karma configuration
// Generated on Thu Oct 02 2014 01:00:22 GMT-0400 (EDT)

module.exports = function(config) {
  
  var js = function(basePath, subPath) { return basePath + subPath + '.{coffee,js}' }
  var spec =   function(subPath) { return js('spec/javascripts/', subPath)}
  var app =    function(subPath) { return js('app/assets/javascripts/', subPath) }
  var vendor = function(subPath) { return js('vendor/assets/javascripts/', subPath) }
  var bower =  function(subPath) { return js('bower_components/', subPath) }

  config.set({

    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: '../',

    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['jasmine'],

    // list of files / patterns to load in the browser
    files: [
      bower('angular/angular'), 
      bower('angular-mocks/angular-mocks'),
      bower('active-support/lib/active-support'),
      bower('lodash/dist/lodash'),
      bower('async/lib/async'),
      app('lib/base_class/base_class'),
      app('lib/base_class/base/**/*'),
      spec('mocks/mocks'),
      spec('mocks/*'),
      spec('lib/base_class/spec_helper'),
      spec('lib/base_class/**/*.spec'),
    ],


    // list of files to exclude
    exclude: [
    ],


    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
      '**/*.coffee': ['coffee']
    },


    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['progress'],


    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,


    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['PhantomJS'],

    // If browser does not capture in given timeout [ms], kill it
    captureTimeout: 60000,


    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: false
  });
};
