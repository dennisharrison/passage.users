'use strict';

var request = require('request');

module.exports = function (grunt) {
  var reloadPort = 35729, files, cssfiles;
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-less');

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    develop: {
      server: {
        file: 'app.js'
      }
    },
    less: {
      compile: {
        options: {
          paths: ['less/bootstrap'],
          strictImports: true,
          yuicompress: true
        },
        files: {
          'public/stylesheets/style.css': 'less/style.less'
        }
      }
    },
    coffee: {
      compileServer: {
        options: {
          sourceMap: true
        },
        files: {
          'app.js': 'app.coffee'
        }
      },
      compileRoutes: {
        options: {
          sourceMap: true
        },
        files: {
          'routes/index.js': 'routes/coffee/*.coffee'
        }
      },
      compileHandlebarsHelpers: {
        options: {
          sourceMap: true
        },
        files: {
          'public/javascripts/handlebars_helpers.js': 'handlebars_helpers/*.coffee'  
        }
      },
      compilePublic: {
        options: {
          sourceMap: true
        },
        files: {
          'public/javascripts/public.js': 'public/coffeescripts/*.coffee'  
        }
      }
    },
    watch: {
      options: {
        nospawn: true,
        livereload: false
      },
      server: {
        files: [
          'app.js',
          'routes/*.js',
          'app.coffee',
          'routes/coffee/*.coffee',
          'handlebars_helpers/*.coffee',
          'public/coffeescripts/*.coffee'
        ],
        tasks: ['coffee:compilePublic', 'coffee:compileHandlebarsHelpers', 'coffee:compileRoutes', 'coffee:compileServer', 'develop', 'delayed-livereload']
      },
      js: {
        files: ['public/js/*.js'],
        options: {
          livereload: reloadPort
        },
      },
      less: {
        files: ['less/*.less'],
        tasks: ['less:compile','css-livereload']
      },
      css: {
        files: ['public/stylesheets/*.css'],
        options: {
          livereload: reloadPort
        },
      },
      handlebars: {
        files: ['views/{,*/}*.html'],
        options: {
          livereload: reloadPort
        },
      }
    }
  });

  grunt.config.requires('watch.server.files');
  files = grunt.config('watch.server.files');
  files = grunt.file.expand(files);

  grunt.registerTask('delayed-livereload', 'Live reload after the node server has restarted.', function () {
    var done = this.async();
    setTimeout(function () {
      request.get('http://localhost:' + reloadPort + '/changed?files=' + files.join(','),  function (err, res) {
          var reloaded = !err && res.statusCode === 200;
          if (reloaded) {
            grunt.log.ok('Delayed live reload successful.');
          } else {
            grunt.log.error('Unable to make a delayed live reload.');
          }
          done(reloaded);
        });
    }, 500);
  });

  grunt.config.requires('watch.css.files');
  cssfiles = grunt.config('watch.css.files');
  cssfiles = grunt.file.expand(cssfiles);
  grunt.registerTask('css-livereload', 'Live reload after the node server has restarted.', function () {
    var done = this.async();
    setTimeout(function () {
      request.get('http://localhost:' + reloadPort + '/changed?files=' + cssfiles.join(','),  function (err, res) {
          var reloaded = !err && res.statusCode === 200;
          if (reloaded) {
            grunt.log.ok('Delayed live reload successful.');
          } else {
            grunt.log.error('Unable to make a delayed live reload.');
          }
          done(reloaded);
        });
    }, 750);
  });

  grunt.loadNpmTasks('grunt-develop');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('default', [
    'coffee:compilePublic',
    'coffee:compileHandlebarsHelpers',
    'coffee:compileRoutes',
    'coffee:compileServer',
    'less:compile',
    'develop',
    'watch']);
};
